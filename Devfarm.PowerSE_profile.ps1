if (Test-Path -LiteralPath $profile.CurrentUserPowerShellHost) {
	. $profile.CurrentUserPowerShellHost
}