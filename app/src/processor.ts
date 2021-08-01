import {Datastore} from "@google-cloud/datastore";
import {withTiming} from './timing';

interface Item {
  id: string;
  value: string;
}

const datastore: Datastore = new Datastore();

function splitToChunks(array: any[], chunkSize: number = 200): any[][] {
  const chunks: any[][] = [];
  let j: number;
  let i: number;
  for (i = 0, j = array.length; i < j; i += chunkSize) {
    const chunk: any[] = array.slice(i, i + chunkSize);
    chunks.push(chunk);
  }
  return chunks;
}

export const processItems = async (items: Item[]): Promise<any> => {
  return withTiming(() => processItemsInternally(items), {
    "action": "processItems",
    count: items.length
  });
}

const processItemsInternally = async (items: Item[]): Promise<any> => {
  const itemChunks: any[][] = splitToChunks(items);

  const updatePromises: Promise<any>[] = itemChunks.map((chunk, _) => withTiming(() => updateChunk(chunk), {
    "action": "updateChunk",
    count: chunk.length
  }));
  await Promise.all(updatePromises);

  return "yupp " + itemChunks.length + " chunk(s) processed";
};

async function updateChunk(items: Item[]) {
  const kind = 'entity';

  const entities = items.map((item: Item) => {
    const key = datastore.key([
      kind,
      datastore.int(item.id)
    ]);
    return {key, data: {value: item.value}};
  });
  const commitResults: any = await datastore.save(entities);
}


