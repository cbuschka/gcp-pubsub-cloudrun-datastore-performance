import express from "express";
import {processItems} from "./processor";
import * as os from 'os';
import cluster from 'cluster';


const app = express();
app.use(express.json({limit: '200mb'}));

const getPort = (defaultPort: number): number => {
  const envPort = process.env.PORT;
  if (envPort) {
    return parseInt(envPort, 10);
  }
  return defaultPort;
}

app.get("/", (req, res) => {
  res.send("It's all ok.");
});

app.post("/events", async (req, res, next) => {
  try {
    const body = await req.body;
    const envelope = body.message;
    const message = JSON.parse(Buffer.from(envelope.data, 'base64').toString());
    const result = await processItems(message.batchId, message.items);
    res.send(result);
  } catch (e) {
    next(e);
  }
});

export const runServer = () => {
  const clusterWorkerSize = os.cpus().length;
  const port = getPort(8080);

  if (clusterWorkerSize > 1) {

    if (cluster.isMaster) {
      for (let i = 0; i < clusterWorkerSize; i++) {
        // tslint:disable-next-line:no-console
        console.log("Forking #%d...", i);
        cluster.fork();
      }

      cluster.on("exit", (worker) => {
        // tslint:disable-next-line:no-console
        console.log("Worker", worker.id, " has exited.")
      });
    } else {
      app.listen(port, '0.0.0.0', () => {
        // tslint:disable-next-line:no-console
        console.log(`Server listening on http://localhost:${port}...`);
      });
    }
  } else {
    app.listen(port, '0.0.0.0', () => {
      // tslint:disable-next-line:no-console
      console.log(`Server listening on http://localhost:${port}...`);
    });
  }

  ["SIGTERM", "SIGINT"].forEach((signal) => {
    process.on(signal, () => {
      // tslint:disable-next-line:no-console
      console.info('SIGTERM/SIGINT signal received. Exiting...');
      process.exit(0);
    });
  });
}
