{{flutter_js}}
{{flutter_build_config}}

const sudokuConfig = {
  canvasKitVariant: 'full',
  canvasKitBaseUrl: new URL("canvaskit/", document.baseURI).href,
  fontFallbackBaseUrl: new URL("assets/fonts/", document.baseURI).href,
};

_flutter.loader.load({
  config: sudokuConfig,
  onEntrypointLoaded: async (engineInitializer) => {
    const runner = await engineInitializer.initializeEngine(sudokuConfig);
    await runner.runApp();
    document.getElementById("loading")?.remove();
  },
}).catch(() => {
  const message = document.getElementById("loading");
  if (message) message.textContent = navigator.language.startsWith("de")
    ? "Sudoku konnte nicht geladen werden. Bitte lade die Seite neu."
    : "Sudoku could not load. Please reload the page.";
});
