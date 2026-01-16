
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
{ "type": "<event.type>", "data": { "..." }, "sender": { "id": "user-uuid", "username": "alice", "email": "alice@example.com" } }
```

Server -> client messages follow the same `{ type, ... }` pattern. There are a few reserved message types used by the server:

- `connection_ack` — acknowledgement on successful connect (includes board info)
- `error` — indicates a protocol or authorization error; contains `message` string

## Available commands

The following commands are currently supported by the server. Each command must be sent as a JSON object with `type` and `data` fields.

### Command reference

**Column commands:**

- [`column.create`](#columncreate) - Create a new column
- [`column.list`](#columnlist) - List all columns
- [`column.rename`](#columnrename) - Rename a column
- [`column.move`](#columnmove) - Move a column to a different position
- [`column.delete`](#columndelete) - Delete a column

**Card commands:**

- [`card.create`](#cardcreate) - Create a new card
- [`card.list`](#cardlist) - List all cards in a column
- [`card.delete`](#carddelete) - Delete a card
- [`card.update`](#cardupdate) - Update a card

**Assignee commands:**

- [`assignee.assign`](#assigneeassign) - Assign a user to a card
- [`assignee.unassign`](#assigneeunassign) - Unassign a user from a card
- [`assignee.list`](#assigneelist) - List all assignees of a card

**Chat commands:**

- [`chat.send`](#chatsend) - Send a chat message to the board
- [`chat.history`](#chathistory) - Retrieve chat message history for the board

---

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
    "id": "user-uuid",
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
    "id": "user-uuid",
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
    "id": "user-uuid",
    "username": "alice",
    "email": "alice@example.com"
  }
}
```

#### `column.move`

Moves a column to a different position in the board.

**Request (client -> server):**

```json
{
  "type": "column.move",
  "data": {
    "id": "column-uuid",
    "newPos": "target-column-uuid"
  }
}
```

**Note:** `newPos` is the ID of the column before which the moved column should be placed. If `newPos` is `null`, the column will be moved to the end.

**Response (server -> all clients including sender):**

```json
{
  "type": "column.move",
  "data": {
    "id": "column-uuid",
    "title": "Column Title",
    "boardId": "board-uuid",
    "index": 2,
    "createdAt": "2025-11-07T09:00:00.000Z",
    "updatedAt": "2025-11-07T09:30:00.000Z"
  },
  "sender": {
    "id": "user-uuid",
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
    "id": "user-uuid",
    "username": "alice",
    "email": "alice@example.com"
  }
}
```

---

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
    "id": "user-uuid",
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
    "id": "user-uuid",
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
    "id": "user-uuid",
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
    "dueDate": "2025-11-15T18:00:00Z"
  }
}
```

**Note:**

- Only `id` is required
- Any combination of the other fields can be provided for partial updates
- Set `tagId`, `startDate`, or `dueDate` to `null` to clear them
- `columnId` can be changed to move the card between columns
- `index` can be changed to reorder the card within its column (or new column if `columnId` is also changed). It is up to the server to adjust other cards' indices accordingly when a card is moved within the same column.
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
    "id": "user-uuid",
    "username": "alice",
    "email": "alice@example.com"
  }
}
```

---

### Assignee commands

#### `assignee.assign`

Assigns a user to a card.

**Request (client -> server):**

```json
{
  "type": "assignee.assign",
  "data": {
    "cardId": "card-uuid",
    "userId": "user-uuid"
  }
}
```

**Response (server -> all clients including sender):**

```json
{
  "type": "assignee.assign",
  "data": {
    "user": {
      "id": "user-uuid",
      "username": "bob",
      "email": "bob@example.com"
    },
    "cardId": "card-uuid"
  },
  "sender": {
    "id": "user-uuid",
    "username": "alice",
    "email": "alice@example.com"
  }
}
```

#### `assignee.unassign`

Unassigns a user from a card.

**Request (client -> server):**

```json
{
  "type": "assignee.unassign",
  "data": {
    "cardId": "card-uuid",
    "userId": "user-uuid"
  }
}
```

**Response (server -> all clients including sender):**

```json
{
  "type": "assignee.unassign",
  "data": {
    "userId": "user-uuid",
    "cardId": "card-uuid"
  },
  "sender": {
    "id": "user-uuid",
    "username": "alice",
    "email": "alice@example.com"
  }
}
```

**Note:** This action can also be broadcasted automatically by the server when a board member is removed via the PUT `/api/boards/:boardId` endpoint. In this case, the broadcast will include a system sender:

```json
{
  "type": "assignee.unassign",
  "data": {
    "cardId": "card-uuid",
    "userId": "user-uuid"
  },
  "sender": {
    "id": "system",
    "username": "system",
    "email": "system@trello.local"
  }
}
```

#### `assignee.list`

Lists all users assigned to a card.

**Request (client -> server):**

```json
{
  "type": "assignee.list",
  "data": {
    "cardId": "card-uuid"
  }
}
```

**Response (server -> all clients including sender):**

```json
{
  "type": "assignee.list",
  "data": {
    "cardId": "card-uuid",
    "assignees": [
      {
        "id": "user-uuid-1",
        "username": "bob",
        "email": "bob@example.com"
      },
      {
        "id": "user-uuid-2",
        "username": "charlie",
        "email": "charlie@example.com"
      }
    ]
  },
  "sender": {    "id": "user-uuid",    "username": "alice",
    "email": "alice@example.com"
  }
}
```

---

### Chat commands

#### `chat.send`

Sends a chat message that is persisted to the database and broadcasted to all clients in the board room.

**Request (client -> server):**

```json
{
  "type": "chat.send",
  "data": "Hello, this is my message!"
}
```

**Response (server -> all clients including sender):**

```json
{
  "type": "chat.send",
  "data": {
    "content": "Hello, this is my message!",
    "createdAt": "2025-11-07T09:30:00.000Z"
  },
  "sender": {
    "id": "user-uuid",
    "username": "alice",
    "email": "alice@example.com"
  }
}
```

#### `chat.history`

Retrieves the chat message history for the current board.

**Request (client -> server):**

```json
{
  "type": "chat.history",
  "data": null
}
```

**Response (server -> requesting client only):**

```json
{
  "type": "chat.history",
  "data": [
    {
      "id": "message-uuid-1",
      "content": "First message",
      "createdAt": "2025-11-07T09:00:00.000Z",
      "user": {
        "id": "user-uuid-1",
        "username": "alice",
        "email": "alice@example.com",
        "createdAt": "2025-11-01T10:00:00.000Z",
        "updatedAt": "2025-11-01T10:00:00.000Z"
      }
    },
    {
      "id": "message-uuid-2",
      "content": "Second message",
      "createdAt": "2025-11-07T09:15:00.000Z",
      "user": {
        "id": "user-uuid-2",
        "username": "bob",
        "email": "bob@example.com",
        "createdAt": "2025-11-02T10:00:00.000Z",
        "updatedAt": "2025-11-02T10:00:00.000Z"
      }
    }
  ],
  "sender": {
    "id": "user-uuid",
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
  "sender": { "id": "user-uuid", "username": "alice", "email": "alice@example.com" }
}
```

## Extensibility / future notes

- Consider adding optional presence events (`user.join`/`user.leave`) if the UI needs explicit presence updates.
- Consider a ping/pong or heartbeat if clients need stronger liveness detection beyond WebSocket-level pings.
- If you need per-message acknowledgements add a `messageId` field and a `ack` type to confirm delivery.

## Version

This document describes the protocol implemented in the server at commit time. Update this file if server message formats or handshake behaviour change.
