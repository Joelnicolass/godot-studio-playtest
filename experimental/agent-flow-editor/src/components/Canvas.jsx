import { forwardRef, useCallback, useEffect, useImperativeHandle, useRef, useState } from "react";
import { portPos, uid } from "../graph.js";
import Cables from "./Cables.jsx";
import FlowNode from "./FlowNode.jsx";

const ZOOM_MIN = 0.25;
const ZOOM_MAX = 2.5;
const ZOOM_STEP = 1.15;

function clampZoom(z) {
  return Math.min(ZOOM_MAX, Math.max(ZOOM_MIN, z));
}

const Canvas = forwardRef(function Canvas(
  {
    nodes,
    setNodes,
    edges,
    setEdges,
    selected,
    setSelected,
    link,
    setLink,
    drag,
    zoom,
    setZoom,
  },
  ref
) {
  const canvas = useRef(null);
  const [pan, setPan] = useState({ x: 0, y: 0 });
  const panRef = useRef(pan);
  panRef.current = pan;
  const zoomRef = useRef(zoom);
  zoomRef.current = zoom;
  const panDrag = useRef(null);
  const [panning, setPanning] = useState(false);

  function toWorld(e) {
    const rect = canvas.current.getBoundingClientRect();
    const p = panRef.current;
    const z = zoomRef.current;
    return {
      x: (e.clientX - rect.left - p.x) / z,
      y: (e.clientY - rect.top - p.y) / z,
    };
  }

  function applyZoom(next, cx, cy) {
    const z = zoomRef.current;
    const nz = clampZoom(next);
    if (nz === z) return;
    const p = panRef.current;
    const wx = (cx - p.x) / z;
    const wy = (cy - p.y) / z;
    setZoom(nz);
    setPan({ x: cx - wx * nz, y: cy - wy * nz });
  }

  function zoomAroundCenter(factor) {
    const el = canvas.current;
    if (!el) return;
    const rect = el.getBoundingClientRect();
    applyZoom(zoomRef.current * factor, rect.width / 2, rect.height / 2);
  }

  function zoomReset() {
    setZoom(1);
    setPan({ x: 0, y: 0 });
  }

  useImperativeHandle(ref, () => ({
    zoomAroundCenter,
    zoomReset,
  }));

  useEffect(() => {
    const el = canvas.current;
    if (!el) return;
    function onWheel(e) {
      e.preventDefault();
      const rect = el.getBoundingClientRect();
      const factor = e.deltaY < 0 ? ZOOM_STEP : 1 / ZOOM_STEP;
      applyZoom(zoomRef.current * factor, e.clientX - rect.left, e.clientY - rect.top);
    }
    el.addEventListener("wheel", onWheel, { passive: false });
    return () => el.removeEventListener("wheel", onWheel);
  }, []);

  const onMove = useCallback(
    (e) => {
      if (panDrag.current) {
        const { sx, sy, ox, oy } = panDrag.current;
        setPan({ x: ox + (e.clientX - sx), y: oy + (e.clientY - sy) });
        return;
      }
      const { x, y } = toWorld(e);
      if (drag.current) {
        const { id, ox, oy } = drag.current;
        setNodes((ns) => ns.map((n) => (n.id === id ? { ...n, x: x - ox, y: y - oy } : n)));
      }
      if (link) setLink((l) => ({ ...l, x, y }));
    },
    [drag, link, setLink, setNodes]
  );

  function startLink(e, node, handle) {
    e.stopPropagation();
    const p = portPos(node, handle);
    setLink({ from: node.id, handle, x: p.x, y: p.y });
  }

  function endLink(e, node) {
    e.stopPropagation();
    if (!link || link.from === node.id) {
      setLink(null);
      return;
    }
    setEdges((es) => {
      const next = es.filter(
        (ed) => !(ed.from === link.from && (ed.handle || "out") === link.handle)
      );
      next.push({ id: uid("e"), from: link.from, to: node.id, handle: link.handle });
      return next;
    });
    setLink(null);
  }

  function endPointer(e) {
    drag.current = null;
    if (panDrag.current) {
      panDrag.current = null;
      setPanning(false);
    }
    if (link) setLink(null);
    if (canvas.current?.hasPointerCapture?.(e.pointerId)) {
      canvas.current.releasePointerCapture(e.pointerId);
    }
  }

  const grid = 22 * zoom;

  return (
    <div
      className={`canvas${panning ? " panning" : ""}`}
      ref={canvas}
      role="application"
      aria-label="Blueprints"
      style={{
        backgroundSize: `${grid}px ${grid}px`,
        backgroundPosition: `${pan.x}px ${pan.y}px`,
      }}
      onPointerMove={onMove}
      onPointerUp={endPointer}
      onPointerCancel={endPointer}
      onPointerDown={(e) => {
        if (e.button !== 0 && e.button !== 1) return;
        e.preventDefault();
        setSelected(null);
        panDrag.current = {
          sx: e.clientX,
          sy: e.clientY,
          ox: panRef.current.x,
          oy: panRef.current.y,
        };
        setPanning(true);
        canvas.current.setPointerCapture(e.pointerId);
      }}
    >
      <div
        className="world"
        style={{ transform: `translate(${pan.x}px, ${pan.y}px) scale(${zoom})` }}
      >
        <Cables nodes={nodes} edges={edges} link={link} />
        {nodes.map((node) => (
          <FlowNode
            key={node.id}
            node={node}
            selected={selected === node.id}
            onSelect={(e) => {
              e.stopPropagation();
              setSelected(node.id);
              const { x, y } = toWorld(e);
              drag.current = {
                id: node.id,
                ox: x - node.x,
                oy: y - node.y,
              };
              canvas.current.setPointerCapture(e.pointerId);
            }}
            onStartLink={startLink}
            onEndLink={endLink}
          />
        ))}
      </div>
      <div className="banner">
        Rueda = zoom · arrastrá el vacío para desplazar · out = next · loop = repeat · Backspace borra
      </div>
    </div>
  );
});

export default Canvas;
export { ZOOM_STEP };
