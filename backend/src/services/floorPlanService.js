'use strict';

// ─────────────────────────────────────────────
// SVG Floor Plan Generator
// ─────────────────────────────────────────────

const ROOM_COLORS = {
  living_room: '#E8F4FD',
  kitchen: '#FFF8E1',
  bedroom: '#F3E5F5',
  bathroom: '#E0F7FA',
  garage: '#ECEFF1',
  garden: '#E8F5E9',
  balcony: '#FFF3E0',
  entrance: '#FCE4EC',
  foyer: '#FCE4EC',
  corridor: '#F5F5F5',
  dining_room: '#FFF9C4',
  study: '#E8EAF6',
  laundry: '#E0F2F1',
  utility: '#EFEBE9',
  default: '#F9F9F9'
};

const ROOM_STROKE = {
  living_room: '#1565C0',
  kitchen: '#E65100',
  bedroom: '#6A1B9A',
  bathroom: '#00695C',
  garage: '#37474F',
  garden: '#2E7D32',
  balcony: '#E65100',
  entrance: '#880E4F',
  foyer: '#880E4F',
  corridor: '#757575',
  default: '#424242'
};

// ─────────────────────────────────────────────
// Scale from real units to SVG pixels
// ─────────────────────────────────────────────
const buildScaler = (plotLength, plotWidth, unit, svgWidth, svgHeight, padding) => {
  const drawW = svgWidth - padding * 2;
  const drawH = svgHeight - padding * 2;

  // Convert to feet if meters
  const lenFt = unit === 'meters' ? plotLength * 3.28084 : plotLength;
  const widFt = unit === 'meters' ? plotWidth * 3.28084 : plotWidth;

  const scaleX = drawW / lenFt;
  const scaleY = drawH / widFt;
  const scale = Math.min(scaleX, scaleY);

  return {
    toSVGX: (ft) => padding + ft * scale,
    toSVGY: (ft) => padding + ft * scale,
    toSVGW: (ft) => ft * scale,
    toSVGH: (ft) => ft * scale,
    scale,
    lenFt,
    widFt
  };
};

// ─────────────────────────────────────────────
// Draw a single room
// ─────────────────────────────────────────────
const drawRoom = (room, scaler, fontSize) => {
  const type = (room.type || 'default').toLowerCase();
  const fill = ROOM_COLORS[type] || ROOM_COLORS.default;
  const stroke = ROOM_STROKE[type] || ROOM_STROKE.default;

  // Convert room dimensions to SVG coordinates
  const unitFactor = room.unit === 'meters' ? 3.28084 : 1;
  const x = scaler.toSVGX((room.position_x || 0) * unitFactor);
  const y = scaler.toSVGY((room.position_y || 0) * unitFactor);
  const w = scaler.toSVGW((room.width_ft || room.width_m * 3.28084 || 10) * unitFactor);
  const h = scaler.toSVGH((room.length_ft || room.length_m * 3.28084 || 10) * unitFactor);

  const centerX = x + w / 2;
  const centerY = y + h / 2;
  const name = room.name || type.replace('_', ' ');
  const area = room.area_sqft ? `${Math.round(room.area_sqft)} sq ft` : '';

  let svgParts = [`<rect x="${x.toFixed(1)}" y="${y.toFixed(1)}" width="${w.toFixed(1)}" height="${h.toFixed(1)}" fill="${fill}" stroke="${stroke}" stroke-width="2" rx="2"/>`];

  // Room label
  svgParts.push(`<text x="${centerX.toFixed(1)}" y="${(centerY - fontSize * 0.6).toFixed(1)}" text-anchor="middle" dominant-baseline="middle" font-size="${fontSize}px" font-family="Arial, sans-serif" font-weight="600" fill="${stroke}">${name}</text>`);

  // Area label
  if (area && h > fontSize * 3) {
    svgParts.push(`<text x="${centerX.toFixed(1)}" y="${(centerY + fontSize * 0.8).toFixed(1)}" text-anchor="middle" dominant-baseline="middle" font-size="${(fontSize * 0.75).toFixed(1)}px" font-family="Arial, sans-serif" fill="#666666">${area}</text>`);
  }

  // Door indicator
  if (room.has_door) {
    const doorSide = room.door_side || 'south';
    let doorX1, doorY1, doorX2, doorY2;
    const doorSize = Math.min(w, h) * 0.25;

    switch (doorSide) {
      case 'north':
        doorX1 = centerX - doorSize / 2; doorY1 = y;
        doorX2 = centerX + doorSize / 2; doorY2 = y;
        break;
      case 'south':
        doorX1 = centerX - doorSize / 2; doorY1 = y + h;
        doorX2 = centerX + doorSize / 2; doorY2 = y + h;
        break;
      case 'east':
        doorX1 = x + w; doorY1 = centerY - doorSize / 2;
        doorX2 = x + w; doorY2 = centerY + doorSize / 2;
        break;
      case 'west':
      default:
        doorX1 = x; doorY1 = centerY - doorSize / 2;
        doorX2 = x; doorY2 = centerY + doorSize / 2;
        break;
    }
    svgParts.push(`<line x1="${doorX1.toFixed(1)}" y1="${doorY1.toFixed(1)}" x2="${doorX2.toFixed(1)}" y2="${doorY2.toFixed(1)}" stroke="#FF6F00" stroke-width="4" stroke-linecap="round"/>`);
  }

  // Window indicators
  if (room.has_window && room.window_sides && room.window_sides.length > 0) {
    room.window_sides.forEach((side) => {
      const winSize = Math.min(w, h) * 0.35;
      let wx1, wy1, wx2, wy2;
      switch (side) {
        case 'north': wx1 = centerX - winSize / 2; wy1 = y; wx2 = centerX + winSize / 2; wy2 = y; break;
        case 'south': wx1 = centerX - winSize / 2; wy1 = y + h; wx2 = centerX + winSize / 2; wy2 = y + h; break;
        case 'east': wx1 = x + w; wy1 = centerY - winSize / 2; wx2 = x + w; wy2 = centerY + winSize / 2; break;
        case 'west': default: wx1 = x; wy1 = centerY - winSize / 2; wx2 = x; wy2 = centerY + winSize / 2; break;
      }
      svgParts.push(`<line x1="${wx1.toFixed(1)}" y1="${wy1.toFixed(1)}" x2="${wx2.toFixed(1)}" y2="${wy2.toFixed(1)}" stroke="#29B6F6" stroke-width="3" stroke-linecap="round" stroke-dasharray="4,2"/>`);
    });
  }

  return svgParts.join('\n');
};

// ─────────────────────────────────────────────
// Draw dimension annotations
// ─────────────────────────────────────────────
const drawDimensions = (lenFt, widFt, unit, svgWidth, svgHeight, padding) => {
  const displayLen = unit === 'meters' ? (lenFt / 3.28084).toFixed(1) : lenFt.toFixed(0);
  const displayWid = unit === 'meters' ? (widFt / 3.28084).toFixed(1) : widFt.toFixed(0);
  const unitLabel = unit === 'meters' ? 'm' : 'ft';

  const drawW = svgWidth - padding * 2;
  const drawH = svgHeight - padding * 2;

  return `
    <!-- Dimension annotations -->
    <line x1="${padding}" y1="${svgHeight - padding / 2}" x2="${padding + drawW}" y2="${svgHeight - padding / 2}" stroke="#666" stroke-width="1"/>
    <line x1="${padding}" y1="${svgHeight - padding / 2 - 5}" x2="${padding}" y2="${svgHeight - padding / 2 + 5}" stroke="#666" stroke-width="1"/>
    <line x1="${padding + drawW}" y1="${svgHeight - padding / 2 - 5}" x2="${padding + drawW}" y2="${svgHeight - padding / 2 + 5}" stroke="#666" stroke-width="1"/>
    <text x="${(padding + drawW / 2).toFixed(1)}" y="${(svgHeight - padding / 4).toFixed(1)}" text-anchor="middle" font-size="12px" font-family="Arial" fill="#444">${displayLen} ${unitLabel}</text>

    <line x1="${padding / 2}" y1="${padding}" x2="${padding / 2}" y2="${padding + drawH}" stroke="#666" stroke-width="1"/>
    <line x1="${padding / 2 - 5}" y1="${padding}" x2="${padding / 2 + 5}" y2="${padding}" stroke="#666" stroke-width="1"/>
    <line x1="${padding / 2 - 5}" y1="${padding + drawH}" x2="${padding / 2 + 5}" y2="${padding + drawH}" stroke="#666" stroke-width="1"/>
    <text x="${(padding / 4).toFixed(1)}" y="${(padding + drawH / 2).toFixed(1)}" text-anchor="middle" font-size="12px" font-family="Arial" fill="#444" transform="rotate(-90, ${(padding / 4).toFixed(1)}, ${(padding + drawH / 2).toFixed(1)})">${displayWid} ${unitLabel}</text>
  `;
};

// ─────────────────────────────────────────────
// Draw legend
// ─────────────────────────────────────────────
const drawLegend = (rooms, svgWidth, yOffset) => {
  const types = [...new Set(rooms.map((r) => r.type || 'default'))];
  const items = types.slice(0, 8); // max 8 in legend
  const legendX = svgWidth - 180;

  let legend = `<g transform="translate(${legendX}, ${yOffset})">
    <rect x="0" y="0" width="170" height="${items.length * 22 + 30}" fill="white" stroke="#ddd" stroke-width="1" rx="4"/>
    <text x="85" y="18" text-anchor="middle" font-size="11px" font-family="Arial" font-weight="bold" fill="#333">Legend</text>`;

  items.forEach((type, i) => {
    const fill = ROOM_COLORS[type] || ROOM_COLORS.default;
    const stroke = ROOM_STROKE[type] || ROOM_STROKE.default;
    const label = type.replace('_', ' ').replace(/\b\w/g, (l) => l.toUpperCase());
    const rowY = 30 + i * 22;
    legend += `
    <rect x="10" y="${rowY}" width="16" height="14" fill="${fill}" stroke="${stroke}" stroke-width="1.5" rx="1"/>
    <text x="32" y="${rowY + 11}" font-size="11px" font-family="Arial" fill="#444">${label}</text>`;
  });

  // Symbols
  legend += `
    <line x1="10" y1="${30 + items.length * 22 + 8}" x2="26" y2="${30 + items.length * 22 + 8}" stroke="#FF6F00" stroke-width="4" stroke-linecap="round"/>
    <text x="32" y="${30 + items.length * 22 + 12}" font-size="10px" font-family="Arial" fill="#666">Door</text>
    <line x1="80" y1="${30 + items.length * 22 + 8}" x2="96" y2="${30 + items.length * 22 + 8}" stroke="#29B6F6" stroke-width="3" stroke-dasharray="4,2"/>
    <text x="102" y="${30 + items.length * 22 + 12}" font-size="10px" font-family="Arial" fill="#666">Window</text>`;

  legend += '</g>';
  return legend;
};

// ─────────────────────────────────────────────
// Draw compass rose
// ─────────────────────────────────────────────
const drawCompass = (x, y, size) => `
  <g transform="translate(${x}, ${y})">
    <circle cx="0" cy="0" r="${size}" fill="white" stroke="#999" stroke-width="1"/>
    <polygon points="0,${-size * 0.8} ${size * 0.3},0 0,${size * 0.2}" fill="#E53935"/>
    <polygon points="0,${size * 0.8} ${-size * 0.3},0 0,${-size * 0.2}" fill="#90A4AE"/>
    <text x="0" y="${-size - 4}" text-anchor="middle" font-size="10px" font-family="Arial" font-weight="bold" fill="#E53935">N</text>
    <text x="${size + 4}" y="4" text-anchor="start" font-size="9px" font-family="Arial" fill="#555">E</text>
    <text x="0" y="${size + 12}" text-anchor="middle" font-size="9px" font-family="Arial" fill="#555">S</text>
    <text x="${-size - 4}" y="4" text-anchor="end" font-size="9px" font-family="Arial" fill="#555">W</text>
  </g>`;

// ─────────────────────────────────────────────
// Main: Generate SVG Floor Plan
// ─────────────────────────────────────────────
const generateSVGFloorPlan = (rooms, plotDimensions, floors = 1) => {
  if (!rooms || rooms.length === 0) {
    return generatePlaceholderSVG(plotDimensions);
  }

  const { length: plotLength, width: plotWidth, unit = 'feet' } = plotDimensions;

  // Separate rooms by floor
  const floorGroups = {};
  for (let f = 1; f <= floors; f++) {
    floorGroups[f] = rooms.filter((r) => (r.floor || 1) === f);
  }

  const SVG_WIDTH = 900;
  const SVG_PER_FLOOR = 600;
  const PADDING = 60;
  const FLOOR_GAP = 60;
  const HEADER_H = 80;
  const FOOTER_H = 50;

  const totalSVGHeight = HEADER_H + floors * (SVG_PER_FLOOR + FLOOR_GAP) + FOOTER_H;

  const scaler = buildScaler(plotLength, plotWidth, unit, SVG_WIDTH - 200, SVG_PER_FLOOR, PADDING);
  const fontSize = Math.max(8, Math.min(14, scaler.scale * 0.8));

  let floorsSVG = '';
  for (let f = 1; f <= floors; f++) {
    const floorRooms = floorGroups[f] || [];
    const yBase = HEADER_H + (f - 1) * (SVG_PER_FLOOR + FLOOR_GAP);

    floorsSVG += `
    <!-- Floor ${f} -->
    <g transform="translate(0, ${yBase})">
      <text x="50" y="25" font-size="16px" font-family="Arial" font-weight="bold" fill="#1A237E">Floor ${f}</text>

      <!-- Plot boundary -->
      <rect x="${PADDING}" y="${PADDING}" width="${(scaler.toSVGW(scaler.lenFt)).toFixed(1)}" height="${(scaler.toSVGH(scaler.widFt)).toFixed(1)}" fill="white" stroke="#1A237E" stroke-width="3" rx="4"/>

      <!-- Rooms -->
      ${floorRooms.map((room) => drawRoom(room, scaler, fontSize)).join('\n')}

      ${drawDimensions(scaler.lenFt, scaler.widFt, unit, SVG_WIDTH - 200, SVG_PER_FLOOR, PADDING)}

      ${drawLegend(floorRooms, SVG_WIDTH, PADDING)}

      ${drawCompass(SVG_WIDTH - 160, SVG_PER_FLOOR - PADDING - 30, 20)}
    </g>`;
  }

  const totalArea = rooms.reduce((s, r) => s + (r.area_sqft || 0), 0);
  const plotArea = unit === 'meters'
    ? `${(plotLength * plotWidth).toFixed(1)} m²`
    : `${(plotLength * plotWidth).toFixed(0)} sq ft`;

  const svg = `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${SVG_WIDTH}" height="${totalSVGHeight}" viewBox="0 0 ${SVG_WIDTH} ${totalSVGHeight}">
  <defs>
    <style>
      .title { font-family: Arial, sans-serif; }
      .room-label { font-family: Arial, sans-serif; }
    </style>
  </defs>

  <!-- Background -->
  <rect width="${SVG_WIDTH}" height="${totalSVGHeight}" fill="#FAFAFA"/>

  <!-- Header -->
  <rect width="${SVG_WIDTH}" height="${HEADER_H}" fill="#1A237E"/>
  <text x="${SVG_WIDTH / 2}" y="35" text-anchor="middle" font-size="20px" font-family="Arial" font-weight="bold" fill="white">FLOOR PLAN</text>
  <text x="${SVG_WIDTH / 2}" y="58" text-anchor="middle" font-size="13px" font-family="Arial" fill="#90CAF9">
    ${floors} Floor${floors > 1 ? 's' : ''} | Plot: ${plotLength} x ${plotWidth} ${unit} (${plotArea}) | Built Area: ~${Math.round(totalArea)} sq ft
  </text>
  <text x="${SVG_WIDTH / 2}" y="72" text-anchor="middle" font-size="11px" font-family="Arial" fill="#64B5F6">Generated by AI House Planner</text>

  ${floorsSVG}

  <!-- Footer -->
  <g transform="translate(0, ${totalSVGHeight - FOOTER_H})">
    <rect width="${SVG_WIDTH}" height="${FOOTER_H}" fill="#ECEFF1"/>
    <text x="20" y="22" font-size="10px" font-family="Arial" fill="#555">Scale: 1:${Math.round(100 / scaler.scale)} | Units: ${unit}</text>
    <text x="${SVG_WIDTH / 2}" y="22" text-anchor="middle" font-size="10px" font-family="Arial" fill="#555">AI House Planner &amp; Construction Cost Estimator</text>
    <text x="${SVG_WIDTH - 20}" y="22" text-anchor="end" font-size="10px" font-family="Arial" fill="#555">Generated: ${new Date().toLocaleDateString()}</text>
    <text x="${SVG_WIDTH / 2}" y="40" text-anchor="middle" font-size="9px" font-family="Arial" fill="#888">For planning purposes only. Consult a licensed architect for construction.</text>
  </g>
</svg>`;

  return svg;
};

// ─────────────────────────────────────────────
// Placeholder SVG when no rooms provided
// ─────────────────────────────────────────────
const generatePlaceholderSVG = (plotDimensions) => {
  const { length = 50, width = 40, unit = 'feet' } = plotDimensions || {};
  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="800" height="600" viewBox="0 0 800 600">
  <rect width="800" height="600" fill="#F5F5F5"/>
  <rect width="800" height="70" fill="#1A237E"/>
  <text x="400" y="42" text-anchor="middle" font-size="22px" font-family="Arial" font-weight="bold" fill="white">FLOOR PLAN</text>
  <rect x="100" y="120" width="600" height="380" fill="white" stroke="#1A237E" stroke-width="3" rx="4"/>
  <text x="400" y="310" text-anchor="middle" font-size="18px" font-family="Arial" fill="#999">Plot: ${length} x ${width} ${unit}</text>
  <text x="400" y="340" text-anchor="middle" font-size="14px" font-family="Arial" fill="#BBB">Generate floor plan to see the layout</text>
</svg>`;
};

module.exports = {
  generateSVGFloorPlan,
  generatePlaceholderSVG
};
