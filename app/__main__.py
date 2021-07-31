from aiohttp import web, ClientSession as Session
import asyncio
import json
import base64
from gcloud.aio.datastore import Datastore, Key, PathElement
import os

project=os.environ["GCP_PROJECT"]
print("Project is {}".format(project))

async def handle(request):
  text = "Hello, it's all ok."
  return web.Response(text=text)

async def process_event(request):
  body = await request.json()
  pubsub_message = body["message"]
  if isinstance(pubsub_message, dict) and "data" in pubsub_message:
    message = json.loads(base64.b64decode(pubsub_message["data"]).decode("utf-8"))
    items = message["items"]
    results = await asyncio.gather(*[update_item(item) for item in items])
    response = {"request": body, "status": "ok"}
    return web.Response(text=json.dumps(response))

async def update_item(item):
  async with Session() as session:
    ds = Datastore(project=project, session=session)
    id = item["id"]
    entity_key = Key(project, path=[PathElement(kind='entity',id_=id)])
    value = item["value"]
    result = await ds.upsert(entity_key, {"value": value})
    print("item: {} => {}".format(item, result))
    return result

async def process_request(request):
  body = await request.json()
  items = body.get("items", [])
  results = await asyncio.gather(*[update_item(item) for item in items])
  response = {"request": body, "status": "ok"}
  return web.Response(text=json.dumps(response))

app = web.Application()
app.add_routes([web.get('/', handle),
                web.post('/events', process_event),
                web.post('/updates', process_request)])

if __name__ == '__main__':
   web.run_app(app)
