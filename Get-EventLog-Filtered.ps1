Get-EventLog System -After (Get-Date).AddHours(-1) | Where-Object {$_.Message -like "The SMS * service entered the * state."}
