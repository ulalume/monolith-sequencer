import websocket from "ws";
import http from "http";

import { app } from "./app";
import { getFirestore, doc, onSnapshot } from "firebase/firestore";

const db = getFirestore(app);

const firestoreInit = async () => {
  try {
    const docRef = doc(db, "game", "board_state");
    onSnapshot(docRef, (doc) => {
      try {
        if (doc.exists()) {
          board = doc.data().board as number[];
          wss.clients.forEach((ws) => ws.send(JSON.stringify(board)));
        }
      } catch (e) {
        console.error("Error: ", e);
      }
    });
  } catch (e) {
    console.error("Error: ", e);
  }
};

const hs: http.Server = http.createServer();

let board: number[] = [
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
];

const wss = new websocket.Server({ server: hs });
wss.on("connection", (ws) => {
  ws.send(JSON.stringify(board));
  ws.on("message", (message) => {
    console.log("from client:", message);
  });
});

hs.listen(5001, () => {
  console.log(`websocket server listening 5001`);
});

firestoreInit();
