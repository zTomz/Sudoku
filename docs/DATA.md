# Data handling in this version

This is a technical inventory, not a completed Store privacy policy.

- No login, backend, analytics, advertising SDK, network game generation or cloud synchronization.
- Games, notes, undo history, time, preferences and completion results are stored locally through shared_preferences. The current validated snapshot and its previous validated recovery copy are retained so a damaged current value can fall back locally.
- Android release has no Internet permission; automatic Android backup is disabled.
- Windows uses the plugin's local/roaming application-data location.
- Web uses browser local storage for saves and Cache Storage for the offline app.
- A website's first load and update checks contact its hosting provider. GitHub/Cloudflare can receive ordinary HTTP request information. No user game data is uploaded by the application.
- Settings store the selected language locally. Version information is read from the installed app; Web reads its hosted version metadata.
- Repository, bug-report and feature-request links open GitHub in the browser only when selected. Sudoku does not attach saves, diagnostics or personal data, and does not submit issues automatically. Copying a failed link writes only that address to the system clipboard.
- Browser or OS tools, backups and extensions are outside the app's control.
- Clearing app/browser data or uninstalling removes local progress; there is no recovery backend.
- Export/import and cross-device synchronization are not implemented.

Before public publication, confirm the final binaries and hosting configuration and provide the actual public privacy-policy URL and Store disclosures. Do not treat this document as proof of a legal compliance claim.
