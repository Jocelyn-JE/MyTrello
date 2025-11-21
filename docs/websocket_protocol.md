
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
{ "type": "connection_ack", "board": { "board object as returned by the DB" } }
```

If the board cannot be found the server replies with an error message and closes the connection.

## Message shapes

All messages are JSON objects. The server expects text frames (UTF-8). Binary frames are not used by the current protocol.

General form (client -> server):

```json
{ "type": "<event.type>", "data": { "..." } }
```

When the server broadcasts a client's message to other clients in the same board room it will attach a `sender` object with minimal public profile information:

```json
{ "type": "<event.type>", "data": { "..." }, "sender": { "username": "alice", "email": "alice@example.com" } }
```

Server -> client messages follow the same `{ type, ... }` pattern. There are a few reserved message types used by the server:

- `connection_ack` — acknowledgement on successful connect (includes board info)
- `error` — indicates a protocol or authorization error; contains `message` string

## Available commands

The following commands are currently supported by the server. Each command must be sent as a JSON object with `type` and `data` fields.

### Column commands

#### `column.create`

Creates a new column in the board.

**Request (client -> server):**

```json
{
  "type": "column.create",
  "data": {
    "title": "Column Title"
  }
}
```

**Response (server -> all clients including sender):**

```json
{
  "type": "column.create",
  "data": {
    "id": "column-uuid",
    "title": "Column Title",
    "boardId": "board-uuid",
    "index": 0,
    "createdAt": "2025-11-07T09:30:00.000Z",
    "updatedAt": "2025-11-07T09:30:00.000Z"
  },
  "sender": {
    "username": "alice",
    "email": "alice@example.com"
  }
}
```

#### `column.list`

Lists all columns in the board.

**Request (client -> server):**

```json
{
  "type": "column.list",
  "data": null
}
```

**Response (server -> all clients including sender):**

```json
{
  "type": "column.list",
  "data": [
    {
      "id": "column-uuid-1",
      "title": "To Do",
      "boardId": "board-uuid",
      "index": 0,
      "createdAt": "2025-11-07T09:00:00.000Z",
      "updatedAt": "2025-11-07T09:00:00.000Z"
    },
    {
      "id": "column-uuid-2",
      "title": "In Progress",
      "boardId": "board-uuid",
      "index": 1,
      "createdAt": "2025-11-07T09:15:00.000Z",
      "updatedAt": "2025-11-07T09:15:00.000Z"
    }
  ],
  "sender": {
    "username": "alice",
    "email": "alice@example.com"
  }
}
```

#### `column.rename`

Renames an existing column in the board.

**Request (client -> server):**

```json
{
  "type": "column.rename",
  "data": {
    "id": "column-uuid",
    "title": "New Column Title"
  }
}
```

**Response (server -> all clients including sender):**

```json
{
  "type": "column.rename",
  "data": {
    "id": "column-uuid",
    "title": "New Column Title",
    "boardId": "board-uuid",
    "index": 0,
    "createdAt": "2025-11-07T09:00:00.000Z",
    "updatedAt": "2025-11-07T09:30:00.000Z"
  },
  "sender": {
    "username": "alice",
    "email": "alice@example.com"
  }
}
```

#### `column.delete`

Deletes a column from the board.

**Request (client -> server):**

```json
{
  "type": "column.delete",
  "data": {
    "id": "column-uuid"
  }
}
```

**Response (server -> all clients including sender):**

```json
{
  "type": "column.delete",
  "data": {
    "id": "column-uuid",
    "title": "Deleted Column",
    "boardId": "board-uuid",
    "index": 0,
    "createdAt": "2025-11-07T09:00:00.000Z",
    "updatedAt": "2025-11-07T09:00:00.000Z"
  },
  "sender": {
    "username": "alice",
    "email": "alice@example.com"
  }
}
```

### Card commands

#### `card.create`

Creates a new card in a column.

**Request (client -> server):**

```json
{
  "type": "card.create",
  "data": {
    "columnId": "column-uuid",
    "title": "Card Title",
    "content": "Card description",
    "tagId": "tag-uuid",
    "startDate": "2025-11-07T10:00:00Z",
    "dueDate": "2025-11-14T18:00:00Z"
  }
}
```

**Note:** Only `columnId` and `title` are required. `content`, `tagId`, `startDate`, and `dueDate` are optional.

**Response (server -> all clients including sender):**

```json
{
  "type": "card.create",
  "data": {
    "id": "card-uuid",
    "columnId": "column-uuid",
    "title": "Card Title",
    "content": "Card description",
    "tagId": "tag-uuid",
    "index": 0,
    "startDate": "2025-11-07T10:00:00.000Z",
    "dueDate": "2025-11-14T18:00:00.000Z",
    "createdAt": "2025-11-07T09:30:00.000Z",
    "updatedAt": "2025-11-07T09:30:00.000Z"
  },
  "sender": {
    "username": "alice",
    "email": "alice@example.com"
  }
}
```

#### `card.list`

Lists all cards in a column.

**Request (client -> server):**

```json
{
  "type": "card.list",
  "data": {
    "columnId": "column-uuid"
  }
}
```

**Response (server -> all clients including sender):**

```json
{
  "type": "card.list",
  "data": [
    {
      "id": "card-uuid-1",
      "columnId": "column-uuid",
      "title": "First card",
      "content": "Details about the card",
      "tagId": null,
      "index": 0,
      "startDate": null,
      "dueDate": null,
      "createdAt": "2025-11-07T09:00:00.000Z",
      "updatedAt": "2025-11-07T09:00:00.000Z"
    },
    {
      "id": "card-uuid-2",
      "columnId": "column-uuid",
      "title": "Second card",
      "content": "More details",
      "tagId": "tag-uuid",
      "index": 1,
      "startDate": "2025-11-07T10:00:00.000Z",
      "dueDate": "2025-11-14T18:00:00.000Z",
      "createdAt": "2025-11-07T09:15:00.000Z",
      "updatedAt": "2025-11-07T09:15:00.000Z"
    }
  ],
  "sender": {
    "username": "alice",
    "email": "alice@example.com"
  }
}
```

#### `card.delete`

Deletes a card from a column.

**Request (client -> server):**

```json
{
  "type": "card.delete",
  "data": {
    "id": "card-uuid"
  }
}
```

**Response (server -> all clients including sender):**

```json
{
  "type": "card.delete",
  "data": {
    "id": "card-uuid",
    "columnId": "column-uuid",
    "title": "Deleted Card",
    "content": "Card description",
    "tagId": null,
    "index": 0,
    "startDate": null,
    "dueDate": null,
    "createdAt": "2025-11-07T09:00:00.000Z",
    "updatedAt": "2025-11-07T09:00:00.000Z"
  },
  "sender": {
    "username": "alice",
    "email": "alice@example.com"
  }
}
```

#### `card.update`

Updates an existing card. Only fields provided in the request will be updated. All fields except `id` are **optional**.

**Request (client -> server):**

```json
{
  "type": "card.update",
  "data": {
    "id": "card-uuid",
    "title": "Updated Title",
    "content": "Updated content",
    "columnId": "different-column-uuid",
    "tagId": "tag-uuid",
    "index": 2,
    "startDate": "2025-11-08T10:00:00Z",
    "dueDate": "2025-11-15T18:00:00Z",
    "assignees": ["user-uuid-1", "user-uuid-2"]
  }
}
```

**Note:**

- Only `id` is required
- Any combination of the other fields can be provided for partial updates
- Set `tagId`, `startDate`, `dueDate`, or `assignees` to `null` to clear them
- `columnId` can be changed to move the card between columns
- `title` and `content` cannot be empty strings

**Response (server -> all clients including sender):**

The server will respond with the full updated card object.

```json
{
  "type": "card.update",
  "data": {
    "id": "card-uuid",
    "columnId": "different-column-uuid",
    "title": "Updated Title",
    "content": "Updated content",
    "tagId": "tag-uuid",
    "index": 2,
    "startDate": "2025-11-08T10:00:00.000Z",
    "dueDate": "2025-11-15T18:00:00.000Z",
    "createdAt": "2025-11-07T09:00:00.000Z",
    "updatedAt": "2025-11-21T14:30:00.000Z"
  },
  "sender": {
    "username": "alice",
    "email": "alice@example.com"
  }
}
```

### Message commands

#### `message`

Sends a message/text to all clients in the board room (simple broadcast).

**Request (client -> server):**

```json
{
  "type": "message",
  "data": "Hello, everyone!"
}
```

**Response (server -> all clients including sender):**

```json
{
  "type": "message",
  "data": "Hello, everyone!",
  "sender": {
    "username": "alice",
    "email": "alice@example.com"
  }
}
```

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

Example client message (create column):

```json
{ "type": "column.create", "data": { "title": "New Column" } }
```

Example server broadcast (received by all clients including sender):

```json
{
  "type": "column.create",
  "data": { "id": "col123", "title": "New Column", "boardId": "board456", "index": 2 },
  "sender": { "username": "alice", "email": "alice@example.com" }
}
```

## Extensibility / future notes

- Consider adding optional presence events (`user.join`/`user.leave`) if the UI needs explicit presence updates.
- Consider a ping/pong or heartbeat if clients need stronger liveness detection beyond WebSocket-level pings.
- If you need per-message acknowledgements add a `messageId` field and a `ack` type to confirm delivery.

## Version

This document describes the protocol implemented in the server at commit time. Update this file if server message formats or handshake behaviour change.
