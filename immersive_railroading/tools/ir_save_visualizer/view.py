"""Matplotlib 3-D view for normalized scene documents."""

from __future__ import annotations

from pathlib import Path

from .model import SceneDocument, SceneObject, WorldPoint


KIND_STYLES = {
    "parent_point": ("#1769aa", "o", 18),
    "gag_point": ("#7b1fa2", "^", 16),
    "curve_control_point": ("#ef6c00", ".", 12),
}
STATUS_COLORS = {
    "CONNECTED": "#2e7d32",
    "DISCONNECTED": "#616161",
    "AMBIGUOUS": "#f9a825",
    "UNTRACED": "#c62828",
    "INVALID": "#ad1457",
}


class SceneView:
    """Own the axes and rendering, leaving selection to ``picking.py``."""

    def __init__(self, figure: object, *, sample_count: int = 64) -> None:
        self._prefer_matching_mplot3d()
        from mpl_toolkits.mplot3d import Axes3D  # noqa: F401 - registers projection
        from matplotlib.projections import register_projection

        register_projection(Axes3D)
        self.figure = figure
        self.axes = figure.add_subplot(111, projection="3d")
        self.sample_count = sample_count
        self.document: SceneDocument | None = None
        self.visible_objects: tuple[SceneObject, ...] = ()

    @staticmethod
    def _prefer_matching_mplot3d() -> None:
        """Avoid mixing a user Matplotlib with a system ``mplot3d`` package.

        Some Linux installations expose ``mpl_toolkits`` as a regular system
        package while Matplotlib itself is installed in the user site.  In
        that arrangement Python otherwise imports the system 3-D toolkit,
        which can be incompatible with the Matplotlib version in use.
        """

        try:
            import matplotlib
            import mpl_toolkits
        except ImportError:
            return
        local_toolkits = Path(matplotlib.__file__).resolve().parent.parent / "mpl_toolkits"
        if local_toolkits.is_dir() and hasattr(mpl_toolkits, "__path__"):
            path = str(local_toolkits)
            if path not in mpl_toolkits.__path__:
                mpl_toolkits.__path__.insert(0, path)

    def _style(self, item: SceneObject) -> tuple[str, str, int]:
        if item.kind in KIND_STYLES:
            color, marker, size = KIND_STYLES[item.kind]
            return STATUS_COLORS.get(item.status or "", color), marker, size
        if item.kind.startswith("topology_"):
            return STATUS_COLORS.get(item.status or "", "#424242"), "x", 20
        return STATUS_COLORS.get(item.status or "", "#424242"), "o", 14

    def render(self, document: SceneDocument, *, enabled_kinds: set[str] | None = None, status: str | None = None, dimension: str | None = None) -> None:
        self.document = document
        self.axes.clear()
        self.axes.set_xlabel("Minecraft X")
        self.axes.set_ylabel("Minecraft Y")
        self.axes.set_zlabel("Minecraft Z")
        self.visible_objects = document.objects_for(enabled_kinds, status, dimension)
        for item in self.visible_objects:
            color, marker, size = self._style(item)
            if item.positions and item.kind != "curve":
                xs, ys, zs = zip(*item.positions)
                self.axes.scatter(xs, ys, zs, c=color, marker=marker, s=size, depthshade=False)
            for polyline in item.polylines:
                if len(polyline) < 2:
                    continue
                xs, ys, zs = zip(*polyline)
                style = "--" if item.kind.startswith("topology_") else "-"
                self.axes.plot(xs, ys, zs, color=color, linestyle=style, linewidth=1.2 if style == "--" else 1.7)
        self._add_legend()
        self._set_bounds()
        self.axes.set_title(f"{document.format} — {'complete' if document.complete else 'incomplete'}")
        self.figure.canvas.draw_idle()

    def _add_legend(self) -> None:
        from matplotlib.lines import Line2D

        handles: list[Line2D] = []
        seen: set[str] = set()
        for item in self.visible_objects:
            label = item.kind.replace("_", " ").title()
            if label in seen:
                continue
            color, marker, _size = self._style(item)
            linestyle = "--" if item.kind.startswith("topology_") else ("-" if item.kind == "curve" else "None")
            handles.append(Line2D([0], [0], color=color, marker=marker, linestyle=linestyle, label=label))
            seen.add(label)
        if handles:
            self.axes.legend(handles=handles, loc="upper left", fontsize="small")

    def _set_bounds(self) -> None:
        points = [point for item in self.visible_objects for point in item.all_geometry]
        if not points:
            self.axes.set_xlim(-1, 1)
            self.axes.set_ylim(-1, 1)
            self.axes.set_zlim(-1, 1)
            self.axes.set_box_aspect((1, 1, 1))
            return
        low = [min(point[index] for point in points) for index in range(3)]
        high = [max(point[index] for point in points) for index in range(3)]
        spans = [max(high[index] - low[index], 1.0) for index in range(3)]
        for index in range(3):
            padding = spans[index] * 0.04
            values = (low[index] - padding, high[index] + padding)
            (self.axes.set_xlim, self.axes.set_ylim, self.axes.set_zlim)[index](*values)
        self.axes.set_box_aspect(tuple(spans))

    def project(self, point: WorldPoint) -> tuple[float, float, float]:
        from mpl_toolkits.mplot3d import proj3d

        x, y, depth = proj3d.proj_transform(point[0], point[1], point[2], self.axes.get_proj())
        screen_x, screen_y = self.axes.transData.transform((x, y))
        return float(screen_x), float(screen_y), float(depth)

    def reset(self) -> None:
        """Reset camera orientation without changing the active document."""

        self.axes.view_init(elev=30, azim=-60)
        self.figure.canvas.draw_idle()
