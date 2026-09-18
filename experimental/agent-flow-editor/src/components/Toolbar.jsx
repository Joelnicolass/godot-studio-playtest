export default function Toolbar({
  busy,
  zoom,
  onCopy,
  onShowJson,
  onImport,
  onRun,
  onZoomIn,
  onZoomOut,
  onZoomReset,
}) {
  const percent = Math.round(zoom * 100);
  return (
    <div className="toolbar">
      <button className="run" disabled={busy === "run"} onClick={onRun}>
        {busy === "run" ? "Running…" : "Run flow"}
      </button>
      <button onClick={onCopy}>Copy JSON</button>
      <button onClick={onShowJson}>Show JSON</button>
      <label className="file">
        Import
        <input
          type="file"
          accept="application/json,.json"
          hidden
          onChange={(e) => {
            const f = e.target.files?.[0];
            if (!f) return;
            f.text().then(onImport);
          }}
        />
      </label>
      <div className="zoom" role="group" aria-label="Zoom">
        <button type="button" onClick={onZoomOut} aria-label="Alejar">
          −
        </button>
        <button type="button" onClick={onZoomReset} title="Restablecer zoom">
          {percent}%
        </button>
        <button type="button" onClick={onZoomIn} aria-label="Acercar">
          +
        </button>
      </div>
    </div>
  );
}
