
# WebSocket protocol

This document describes the WebSocket protocol used by the server for real-time updates on boards.

## Endpoint

- Path: `/ws/boards/:boardId`
- Transport: WebSocket (text frames carrying JSON)

Clients must open a WebSocket connection to the endpoint with the target `boardId` in the URL. After the connection is accepted, the client MUST send a small JSON handshake message containing an authentication token as the first message (the server waits briefly for it).

Example handshake (client -> server):

```json
{ "token": "<JWT or session token>" }
```

If the token is missing or invalid, the server will close the connection with a policy error (see "Close codes and errors").

## Authentication & Authorization

- The server extracts the authenticated user from the token provided in the initial message.
- The server verifies that the authenticated user is a member, owner, or viewer of the requested board. If they are not authorized, the connection is closed.

## Connection acknowledgement

On success the server sends a connection acknowledgement message (text JSON):

```json
{ "type": "connection_ack", "board": { /* board object as returned by the DB */ } }
```

If the board cannot be found the server replies with an error message and closes the connection.

## Message shapes

All messages are JSON objects. The server expects text frames (UTF-8). Binary frames are not used by the current protocol.

General form (client -> server):

```json
{ "type": "<event.type>", "data": { ... } }
```

When the server broadcasts a client's message to other clients in the same board room it will attach a `sender` object with minimal public profile information:

```json
{ "type": "<event.type>", "data": { ... }, "sender": { "username": "alice", "email": "alice@example.com" } }
```

Server -> client messages follow the same `{ type, ... }` pattern. There are a few reserved message types used by the server:

- `connection_ack` — acknowledgement on successful connect (includes board info)
- `error` — indicates a protocol or authorization error; contains `message` string

Application-level event types are free-form strings (e.g. `card.create`, `card.update`, `comment.add`, `cursor.move`) defined by the frontend and server implementation. Each event should include a `data` object with the event payload.

## Broadcasting rules

- When a client sends a message while connected to a board room, the server forwards the parsed JSON payload to every other connected socket for that board (not to the sender), preserving the `type` and `data` fields and adding `sender`.
- The server removes stale sockets from internal room lists when they close or become unusable.

## Presence and rooms

- The server manages rooms keyed by `boardId` and tracks clients per user (multiple sockets per user allowed).
- The server does not currently emit automatic `user.join`/`user.leave` messages; presence may be implemented by the app-level messages if needed.

## Error messages and close codes

Server error message payloads look like:

```json
{ "type": "error", "message": "description of error" }
```

Close codes used by the server:

- `1008` (policy violation) — used for unauthorized connections (invalid/missing token, not a board member) or bad requests.
- `1011` (internal error) — server-side error while handling the connection.
- The server may also use normal closure codes for other conditions; clients should handle unexpected closures and attempt reconnect with backoff.

## Client implementation notes (examples)

- Open a WebSocket to `ws://<host>/ws/boards/<boardId>`.
- Immediately send the handshake JSON with the token.
- Wait for `connection_ack` before sending application events.
- When sending an event include `type` and `data` fields and keep payloads JSON-serializable.

Example client message (create card):

```json
{ "type": "card.create", "data": { "title": "New card", "listId": "abc" } }
```

Example server broadcast (received by other clients):

```json
{
  "type": "card.create",
  "data": { "title": "New card", "listId": "abc", "id": "card123" },
  "sender": { "username": "alice", "email": "alice@example.com" }
}
```

## Extensibility / future notes

- Consider adding optional presence events (`user.join`/`user.leave`) if the UI needs explicit presence updates.
- Consider a ping/pong or heartbeat if clients need stronger liveness detection beyond WebSocket-level pings.
- If you need per-message acknowledgements add a `messageId` field and a `ack` type to confirm delivery.

## Version

This document describes the protocol implemented in the server at commit time. Update this file if server message formats or handshake behaviour change.

---

If anything is missing or you want the doc to include example client code (JS/Flutter) or TypeScript types, tell me which language and I will add a short snippet.
