# A word for frontend developer

The `index.html` in frontend root folder is treated as a [go template](http://golang.org/pkg/text/template/#pkg-overview). The only variable you can use is *site root url*.

# Basic knowledge

### Parameters
APIs receive two kinds of parameter: URI or json.

- URI parameter: passed as part of URI, like `/api/pad/1` in `/api/pad`. You have to pass URI parameters in correct order.
- json parameter: passed in POST data.

APIs which has return data will always return in json format. Mostly with a boolean field named `result` which indicates operation result.

### Image field in user data
This is raw url to the user's avatar.

### Cooperate field in pad data
This is pad's cooperators (people who can edit this pad but not owner).

# APIs

### /api/logout - Logout

- Entry: `/api/logout`

Logout

### /api/paths - Login provider

- Entry: `/api/paths`
- Return: passible login provider
- Return type: `["string"]`

Get possible login method.

Scripts handling login process must first calling this API, then redirect user to `/auth/provider`. For example: if API returns ["google", "fb"], you might provide a dialog, let user choose one of them (say "fb" in this example), and redirect page to `/auth/fb`.

After user login process is finished, user will be redirected back to index page, and you can call `/api/user`  to check if user is logged in.

### /api/me - Get info of logged-in user

- Entry: `/api/me`
- Return: User info object
- Return type: `{"result": boolean, "message": "string", "data": {"name": "string", "image": "string", "id": integer}}`

This API will return current logged in user's data.
You have to check "result" first. if "result" is false, that means user has not logged in.

### /api/user - Get user info

- Entry: `/api/user`
- Parameters: userid (json required)
- Return: User info object
- Return type: `{"result": boolean, "message": "string", "data": [{"name": "string", "image": "string", "id": integer}]}`

The `userid` parameter is an array of integers.

This API will return false in result field when something goes wrong. If users are not found, result will be true, and data will be an empty array.

### /api/users - Get all users info

- Entry: `/api/users`
- Return: Array of user info object
- Return type: `{"result": boolean, "message": "string", "data": [{"name": "string", "image": "string", "id": integer}]}`

### /api/pads - List all pads

- Entry: `/api/pads`
- Return: Array of pad info without content and html
- Return type: `{"result": boolean, "message": "string", "data": [{"title": "string", "user": integer, "cooperator": [integer], "tags": ["string"], "id": integer}]}`

This api lists all pads without their content and html.

### /api/pad - Get pad data

- Entry: `/api/pad`
- Parameters: padid (URI required)
- Return: Array of pad info with content and html
- Return type: `{"result": boolean, "message": "string", "data": {"title": "string", "content": "string", "html": "string", "user": integer, "cooperator": [integer], "tags": ["string"], "version": integer, "id": integer}}`

### /api/edit - Edit pad

- Entry: `/api/edit`
- Parameters: padid (URI required), version (json required), title (json optional), content (json optional), cooperator (json optional), tags (json optional)
- Return: result code
- Return type: `{"result": boolean, "message": "string", "data": {"code": integer}}`

Result code:
- 0: Success.
- 1: Not logged in.
- 2: No such pad.
- 3: Not cooperator.
- 4: Failed to save pad.
- 5: Version not match.

`version` field keeps you from overwriting cooperator's work. Frontend calls `/api/pad` to get pad info, including a version number, then showing UI for user to edit their document. When calling this api to save user's work, you have to pass the version number in `version` field, and backend have to validate it, return fail if not match, so frontend can tell user "Someone has updated this document just before you press SAVE button".

`tags` field is array of string.

You have to pass an array of cooperators' id as `cooperator` field. Use empty array to clear that field.

Only pad owner can edit `cooperate` field.

### /api/create - Create new pad
- Entry: `/api/create`
- Parameters: title (json optional), content (json optional), cooperator (json optional), tags (json optional)
- Return: result code
- Return type: `{"result": boolean, "message": "string", "data": {"code": integer, "id": integer}}`

`tags` field is array of string.

You have to pass an array of cooperators' id as `cooperator` field. Use empty array to clear that field.

Result code:
- 0: Success, pad id is return via `id` field.
- 1: Not logged in.
- 2: Failed to save into database.
- 3: Not permit to create pad.

### /api/delete - Delete pad
- Entry: `/api/delete`
- Parameters: padid (URI required)
- Return: result code
- Return type: `{"result": boolean, "message": "string", "data": {"code": integer}}`

Result code:
- 0: Success.
- 1: Not logged in.
- 2: No such pad.
- 3: Not owner.
- 4: Unknown error.
