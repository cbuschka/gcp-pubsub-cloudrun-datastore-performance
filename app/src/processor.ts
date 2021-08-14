import {Datastore} from "@google-cloud/datastore";
import {withTiming} from './timing';
import {Batcher} from "./batcher";
import os from 'os';

interface Item {
  id: string;
  value: string;
}

const datastore: Datastore = new Datastore();

async function updateChunk(items: Item[]): Promise<any> {
  const kind = 'entity';

  const entities = items.map((item: Item) => {
    const key = datastore.key([
      kind,
      datastore.int(item.id)
    ]);
    return {key, data: {value: item.value}};
  });
  return await datastore.save(entities);
}

const CHUNK_SIZE = 200;
const QUEUE_SIZE = 1000;
const CONCURRENCY_LEVEL = 100;

const batcher: Batcher<Item, any> = new Batcher(updateChunk, 200, 1000, 100);

export const processItems = async (batchId: string, items: Item[]): Promise<any> => {
  const start = new Date();
  const results = await withTiming(() => batcher.execute(batchId, items), {
    "action": "processItems",
    count: items.length
  });
  const end: Date = new Date();
  const duration: number = end.getTime() - start.getTime();
  return {
    batchId,
    itemCount: items.length,
    results,
    duration,
    cpu: os.cpus().length,
    memory: os.totalmem(),
    chunkSize: CHUNK_SIZE,
    queueSize: QUEUE_SIZE,
    concurrencyLevel: CONCURRENCY_LEVEL,
    retry: false
  };
}
