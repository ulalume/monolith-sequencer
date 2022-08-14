import websocket from "ws";
import http from "http";

// UnixドメインソケットでWebSocketを待ち受けるHTTPサーバー
const hs: http.Server = http.createServer();

const board: number[] = [
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 1, -1, 0, 0, 0, 0, 0, 0, -1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
];

// WebSocketサーバー (いわゆるechoサーバーです)
const wss = new websocket.Server({ server: hs }); // 最重要
wss.on("connection", (ws) => {
  ws.send(JSON.stringify(board));
  ws.on("message", (message) => {
    console.log("from client:", message);
  });
});

// HTTPサーバのlistenを開始する
hs.listen(5001, () => {
  console.log(`websocket server listening 5001`);
});
