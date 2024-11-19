import express from "express";
import { Server } from "socket.io";
import http from "http";
import { ReadlineParser, SerialPort } from "serialport";

const app = express();
const server = http.createServer(app);
const port = 4000;

const socket = new Server(server, {
  cors: {
    origin: "*",
  },
});

const serialPort = new SerialPort({
  // path: "/dev/cu.usbmodem114101",
  path: "/dev/cu.usbmodem1101",
  baudRate: 9600,
});

const parser = serialPort.pipe(new ReadlineParser({ delimiter: "\n" }));
let setup = false;
serialPort.on("open", () => {
  parser.on("data", async (data) => {
    if (setup) {
      const { lpg } = JSON.parse(data);
      const lpgValue = Math.abs(lpg);
      console.log(lpgValue);
      return socket.emit("data", Math.abs(lpgValue));
    } else {
      setup = true;
    }
  });
});

server.listen(port, async () => {
  console.log(`http://localhost:${port}`);
});
