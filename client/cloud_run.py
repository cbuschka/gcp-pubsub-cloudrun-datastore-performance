import io
import json
import logging
import os
from typing import Any
from typing import Dict
from typing import List
from typing import Optional
from typing import Union

from gcloud.aio.auth import AioSession  # pylint: disable=no-name-in-module
from gcloud.aio.auth import Token  # pylint: disable=no-name-in-module
from aiohttp import ClientSession as Session  # type: ignore[no-redef]

VERIFY_SSL = True
SCOPES = [
  'https://www.googleapis.com/auth/run',
]

log = logging.getLogger(__name__)


class RunClient:
  def __init__(self, *, service_file: Optional[Union[str, io.IOBase]] = None,
    session: Optional[Session] = None,
    token: Optional[Token] = None) -> None:
    self.session = AioSession(session, verify_ssl=VERIFY_SSL)
    self.token = token or Token(service_file=service_file, scopes=SCOPES,
                                session=self.session.session)

  async def _headers(self) -> Dict[str, str]:
    headers = {
      'Content-Type': 'application/json'
    }

    token = await self.token.get()
    headers['Authorization'] = f'Bearer {token}'
    return headers

  async def list_services(self, project: str, region: str,
    *, session: Optional[Session] = None,
    timeout: Optional[int] = 10) -> List['RunService']:
    url = f'https://{region}-run.googleapis.com/apis/serving.knative.dev/v1/namespaces/{project}/services'
    headers = await self._headers()
    s = AioSession(session) if session else self.session
    resp = await s.get(url, headers=headers, timeout=timeout)
    result: Dict[str, Any] = await resp.json()
    return [RunService(item) for item in result["items"]]

  async def close(self) -> None:
    await self.session.close()

  async def __aenter__(self) -> 'RunClient':
    return self

  async def __aexit__(self, *args: Any) -> None:
    await self.close()


class RunService(object):
  def __init__(self, raw):
    self.raw = raw

  def __getattr__(self, item):
    if item == 'name':
      return self.raw["metadata"]["name"]
    if item == 'url':
      return self.raw["status"]["address"]["url"]

    raise AttributeError
