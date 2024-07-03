# ps-jamf-helper
Utilities to help with jamf stuff. Basically wrappers around Jamf API's

_"Why spend 5 minutes doing something when you can spend 8 hours failing to automate it."_

Basic utils to help with Jamf stuff.
Relies on the environment vars JAMF_ROOT and JAMF_USER.
- `JAMF_ROOT` is the base URI of the jamf instance.
- `JAMF_USER` is the base64 encoded 'username:password' combination

Will figure out the new Jamf API key feature at some point.

```Powershell
# add to current session
$env:JAMF_ROOT = 'https://myschool.com'
$env:JAMF_USER = [convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("${username}:${password}"))
```
```Powershell
# add to environment
setx JAMF_ROOT 'https://myschool.com'
setx JAMF_USER [convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("${username}:${password}"))
```
















