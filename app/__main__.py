from aiohttp import web, ClientSession as Session
import asyncio
import json
import base64
from gcloud.aio.datastore import Datastore, Key, PathElement
import os

semaphore = asyncio.Semaphore(1000)

project = os.environ["GCP_PROJECT"]
print("Project is {}".format(project))


async def process_event(request):
  body = await request.json()
  pubsub_message = body["message"]
  messageId = pubsub_message["messageId"]
  deliveryAttempt = body.get("deliveryAttempt", None)
  print("Received pubsub message {}, deliveryAttempt={}".format(messageId,
                                                                deliveryAttempt))
  if isinstance(pubsub_message, dict) and "data" in pubsub_message:
    message = json.loads(
      base64.b64decode(pubsub_message["data"]).decode("utf-8"))
    items = message["items"]
    await asyncio.gather(*[update_item(item) for item in items])
    response = {"status": "ok", "count": len(items)}
    return web.Response(text=json.dumps(response))


async def update_item(item):
  async with Session() as session:
    ds = Datastore(project=project, session=session)
    id = item["id"]
    entity_key = Key(project, path=[PathElement(kind='entity', id_=id)])
    value = item["value"]
    for turn in range(10):
      async with semaphore:
        result = await ds.upsert(entity_key, {"value": value})
      if result["mutationResults"][0].conflict_detected != True:
        break
      else:
        print("Retrying {} after sleep, because {}...".format(item, result))
        await asyncio.sleep(0.01 * turn)
    return None


async def process_request(request):
  body = await request.json()
  items = body.get("items", [])
  await asyncio.gather(*[update_item(item) for item in items])
  response = {"request": body, "status": "ok"}
  return web.Response(text=json.dumps(response))


app = web.Application()
app.add_routes([web.post('/events', process_event),
                web.post('/updates', process_request)])

if __name__ == '__main__':
  web.run_app(app)
