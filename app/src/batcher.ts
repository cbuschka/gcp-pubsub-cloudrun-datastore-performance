import Semaphore from "semaphore-async-await";

type Chunk<T> = T[];

type ChunkProcessorFunction<T, R> = (chunk: Chunk<T>) => Promise<Chunk<R>>;

export class Batcher<T, R> {
  private enqueueSemaphore: Semaphore;
  private processSemaphore: Semaphore;
  private chunkSize: number;
  private chunkProcessor: ChunkProcessorFunction<T, R>;

  constructor(chunkProcessor: ChunkProcessorFunction<T, R>, chunkSize: number = 2, queueSize: number = 1000, concurrencyLevel: number = 300) {
    this.chunkProcessor = chunkProcessor;
    this.chunkSize = chunkSize;
    this.enqueueSemaphore = new Semaphore(queueSize);
    this.processSemaphore = new Semaphore(concurrencyLevel);
  }

  async execute(id: string, items: T[]): Promise<R[]> {
    const chunks = this.splitToChunks(items);
    return this.enqueueProcessChunks(chunks);
  }

  private async enqueueProcessChunks(chunks: Chunk<T>[]): Promise<R[]> {

    if (this.enqueueSemaphore.getPermits() < chunks.length) {
      throw new Error("Too much chunks in processing.");
    }

    return this.enqueueSemaphore.execute(async (): Promise<any> => {
      return Promise.all(chunks.map((c: Chunk<T>) => this.processChunk(c)));
    });
  }

  private async processChunk(chunk: Chunk<T>): Promise<R[]> {
    return this.processSemaphore.execute(async () => {
      return await this.chunkProcessor(chunk);
    });
  }

  private splitToChunks(tasks: T[]): Chunk<T>[] {
    const chunks: Chunk<T>[] = [];
    let j: number;
    let i: number;
    for (i = 0, j = tasks.length; i < j; i += this.chunkSize) {
      const chunk: Chunk<T> = tasks.slice(i, i + this.chunkSize);
      chunks.push(chunk);
    }
    return chunks;
  }
}

