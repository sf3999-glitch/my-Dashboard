'use strict';

const Anthropic = require('@anthropic-ai/sdk');
const NodeCache = require('node-cache');
const logger = require('../config/logger');

const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
const cache = new NodeCache({ stdTTL: 3600, checkperiod: 120 }); // 1-hour cache

const MODEL = 'claude-opus-4-5';
const MAX_TOKENS = 4096;

// ─────────────────────────────────────────────
// Helper: call Claude with retries
// ─────────────────────────────────────────────
const callClaude = async (systemPrompt, userPrompt, maxRetries = 2) => {
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      const response = await client.messages.create({
        model: MODEL,
        max_tokens: MAX_TOKENS,
        system: systemPrompt,
        messages: [{ role: 'user', content: userPrompt }]
      });
      return response.content[0].text;
    } catch (error) {
      if (attempt === maxRetries) throw error;
      logger.warn(`Claude API attempt ${attempt + 1} failed, retrying...`, error.message);
      await new Promise((r) => setTimeout(r, 1000 * (attempt + 1)));
    }
  }
};

// ─────────────────────────────────────────────
// Helper: parse JSON from Claude response
// ─────────────────────────────────────────────
const parseClaudeJSON = (text) => {
  // Extract JSON from markdown code blocks if present
  const jsonMatch = text.match(/```(?:json)?\s*([\s\S]*?)```/);
  const jsonStr = jsonMatch ? jsonMatch[1] : text;
  try {
    return JSON.parse(jsonStr.trim());
  } catch {
    // Try to find first { or [ and parse from there
    const startIdx = Math.min(
      jsonStr.indexOf('{') !== -1 ? jsonStr.indexOf('{') : Infinity,
      jsonStr.indexOf('[') !== -1 ? jsonStr.indexOf('[') : Infinity
    );
    if (startIdx !== Infinity) {
      return JSON.parse(jsonStr.substring(startIdx));
    }
    throw new Error('Failed to parse JSON from Claude response');
  }
};

// ─────────────────────────────────────────────
// Build project summary for prompts
// ─────────────────────────────────────────────
const buildProjectContext = (project) => {
  const plotArea = project.plot_length && project.plot_width
    ? `${project.plot_length} x ${project.plot_width} ${project.unit}`
    : 'not specified';

  return `
Project: "${project.name}"
Location: ${project.city ? `${project.city}, ` : ''}${project.country || 'Not specified'}
Plot dimensions: ${plotArea}
Floors: ${project.floors}
Bedrooms: ${project.bedrooms}
Bathrooms: ${project.bathrooms}
Kitchen: ${project.kitchen ? 'Yes' : 'No'}
Living room: ${project.living_room ? 'Yes' : 'No'}
Garage: ${project.garage ? 'Yes' : 'No'}
Garden: ${project.garden ? 'Yes' : 'No'}
Balcony: ${project.balcony ? 'Yes' : 'No'}
House style: ${project.house_style || 'Modern'}
Construction quality: ${project.construction_quality || 'standard'}
Currency: ${project.currency || 'USD'}
`.trim();
};

// ─────────────────────────────────────────────
// 1. Generate Floor Plan
// ─────────────────────────────────────────────
const generateFloorPlan = async (project) => {
  const cacheKey = `floor_plan_${project.id}_${project.updated_at}`;
  const cached = cache.get(cacheKey);
  if (cached) return cached;

  const plotLength = parseFloat(project.plot_length);
  const plotWidth = parseFloat(project.plot_width);
  const unit = project.unit || 'feet';

  // Convert to feet for calculations
  const lenFt = unit === 'meters' ? plotLength * 3.28084 : plotLength;
  const widFt = unit === 'meters' ? plotWidth * 3.28084 : plotWidth;
  const totalSqFt = lenFt * widFt;

  const systemPrompt = `You are an expert residential architect and space planning specialist.
You create optimized room layouts based on plot dimensions and client requirements.
You always respond with valid JSON only — no markdown, no explanations, pure JSON.`;

  const userPrompt = `Design an optimal floor plan layout for a ${project.floors}-floor house with the following specifications:

${buildProjectContext(project)}

Total plot area: approximately ${Math.round(totalSqFt)} sq ft (${Math.round(totalSqFt * 0.0929)} sq m)

Design rules:
- Living room and kitchen should be near the front/entrance
- Bedrooms should be private (away from main entrance)
- Bathrooms should be near bedrooms
- Consider natural light and ventilation
- Leave space for corridors (10-15% of total area)
- Account for walls (approximately 5% of area)

Return a JSON object with this exact structure:
{
  "total_floors": number,
  "total_area_sqft": number,
  "house_area_sqft": number,
  "rooms": [
    {
      "id": "room_1",
      "name": "Living Room",
      "type": "living_room",
      "floor": 1,
      "width_ft": number,
      "length_ft": number,
      "area_sqft": number,
      "position_x": number,
      "position_y": number,
      "has_window": boolean,
      "has_door": boolean,
      "door_side": "north|south|east|west",
      "window_sides": ["north", "south"],
      "description": "brief description"
    }
  ],
  "corridors": [
    {
      "floor": 1,
      "width_ft": number,
      "length_ft": number,
      "position_x": number,
      "position_y": number
    }
  ],
  "design_notes": "Brief notes about the design decisions",
  "layout_style": "open|traditional|mixed"
}

Room types to include based on requirements:
${project.living_room ? '- living_room' : ''}
${project.kitchen ? '- kitchen' : ''}
${Array.from({ length: project.bedrooms }, (_, i) => `- bedroom (bedroom ${i + 1})`).join('\n')}
${Array.from({ length: project.bathrooms }, (_, i) => `- bathroom (bathroom ${i + 1})`).join('\n')}
${project.garage ? '- garage' : ''}
${project.garden ? '- garden' : ''}
${project.balcony ? '- balcony' : ''}
- entrance/foyer

Position coordinates use the top-left corner as origin (0,0).
The plot is ${plotLength} ${unit} wide (x-axis) and ${plotWidth} ${unit} tall (y-axis).
If using feet, 1 unit = 1 foot. If meters, 1 unit = 1 meter.`;

  const response = await callClaude(systemPrompt, userPrompt);
  const result = parseClaudeJSON(response);

  cache.set(cacheKey, result);
  return result;
};

// ─────────────────────────────────────────────
// 2. Generate Cost Estimate (AI enhancement)
// ─────────────────────────────────────────────
const generateCostEstimate = async (project, localEstimate) => {
  const cacheKey = `cost_${project.id}_${project.updated_at}`;
  const cached = cache.get(cacheKey);
  if (cached) return cached;

  const systemPrompt = `You are a construction cost estimation expert with 20+ years of experience across global markets.
You provide accurate, detailed construction cost analyses. Respond with valid JSON only.`;

  const userPrompt = `Analyze and enhance this construction cost estimate for the following project:

${buildProjectContext(project)}

Base cost estimate from our calculator:
${JSON.stringify(localEstimate, null, 2)}

Provide an AI analysis with:
1. Validation of the base estimate
2. Country/region specific adjustments
3. Market conditions and trends
4. Risk factors and contingencies
5. Value engineering opportunities
6. Timeline estimate

Return JSON:
{
  "analysis_summary": "2-3 sentence overview",
  "estimate_accuracy": "low|medium|high",
  "confidence_percentage": number,
  "market_adjustment_factor": number,
  "adjusted_total": number,
  "adjusted_currency": "${project.currency || 'USD'}",
  "country_notes": "specific notes about ${project.country || 'the selected'} market",
  "risk_factors": [
    { "factor": "description", "impact": "low|medium|high", "mitigation": "suggestion" }
  ],
  "contingency_percentage": number,
  "contingency_amount": number,
  "value_engineering": [
    { "item": "suggestion", "potential_savings": number, "trade_off": "description" }
  ],
  "construction_timeline": {
    "phases": [
      { "phase": "Foundation & Structure", "duration_weeks": number },
      { "phase": "Roofing & Exterior", "duration_weeks": number },
      { "phase": "MEP (Mechanical, Electrical, Plumbing)", "duration_weeks": number },
      { "phase": "Interior Finishing", "duration_weeks": number },
      { "phase": "Final Inspection & Handover", "duration_weeks": number }
    ],
    "total_weeks": number
  },
  "payment_schedule": [
    { "milestone": "description", "percentage": number, "amount": number }
  ]
}`;

  const response = await callClaude(systemPrompt, userPrompt);
  const result = parseClaudeJSON(response);

  cache.set(cacheKey, result);
  return result;
};

// ─────────────────────────────────────────────
// 3. Generate Material Report
// ─────────────────────────────────────────────
const generateMaterialReport = async (project) => {
  const cacheKey = `materials_${project.id}_${project.updated_at}`;
  const cached = cache.get(cacheKey);
  if (cached) return cached;

  const plotArea = project.plot_length && project.plot_width
    ? parseFloat(project.plot_length) * parseFloat(project.plot_width)
    : 100;
  const unit = project.unit || 'feet';
  const areaInSqFt = unit === 'meters' ? plotArea * 10.764 : plotArea;

  const systemPrompt = `You are a construction materials expert and quantity surveyor.
You provide accurate material take-offs and procurement lists. Respond with valid JSON only.`;

  const userPrompt = `Create a detailed materials report for this construction project:

${buildProjectContext(project)}
Estimated built area: ~${Math.round(areaInSqFt * 0.7)} sq ft (70% of plot)

Provide a comprehensive material list. Consider:
- ${project.construction_quality || 'standard'} quality materials
- Regional availability in ${project.country || 'generic market'}
- ${project.house_style || 'modern'} architectural style

Return JSON:
{
  "summary": {
    "total_estimated_cost": number,
    "currency": "${project.currency || 'USD'}",
    "quality_tier": "${project.construction_quality || 'standard'}",
    "notes": "brief summary"
  },
  "categories": [
    {
      "category": "Foundation & Structure",
      "subcategory_items": [
        {
          "name": "Concrete (Ready Mix)",
          "specification": "M20 grade, 3000 PSI",
          "unit": "cubic yards",
          "quantity": number,
          "unit_cost": number,
          "total_cost": number,
          "notes": "optional notes"
        }
      ],
      "category_total": number
    }
  ],
  "material_categories": [
    "Foundation & Structure",
    "Masonry & Concrete",
    "Roofing",
    "Doors & Windows",
    "Flooring",
    "Electrical",
    "Plumbing",
    "HVAC",
    "Interior Finishing",
    "Exterior Finishing",
    "Insulation",
    "Landscaping"
  ],
  "procurement_tips": [
    "tip 1",
    "tip 2"
  ],
  "alternative_materials": [
    {
      "standard_material": "name",
      "alternative": "name",
      "cost_difference_pct": number,
      "pros": "advantages",
      "cons": "disadvantages"
    }
  ]
}`;

  const response = await callClaude(systemPrompt, userPrompt);
  const result = parseClaudeJSON(response);

  cache.set(cacheKey, result);
  return result;
};

// ─────────────────────────────────────────────
// 4. Generate Optimization Suggestions
// ─────────────────────────────────────────────
const generateOptimizationSuggestions = async (project) => {
  const cacheKey = `suggestions_${project.id}_${project.updated_at}`;
  const cached = cache.get(cacheKey);
  if (cached) return cached;

  const systemPrompt = `You are an expert residential architect and sustainable building consultant.
You provide actionable, evidence-based recommendations to optimize house designs for cost, efficiency, and livability.
Respond with valid JSON only.`;

  const userPrompt = `Analyze this house project and provide comprehensive optimization suggestions:

${buildProjectContext(project)}

${project.cost_estimate ? `Estimated total cost: ${project.currency || 'USD'} ${project.cost_estimate.total_cost || 'N/A'}` : ''}
${project.ai_floor_plan ? `Total area: ~${project.total_area_sqft || 'N/A'} sq ft` : ''}

Provide detailed optimization recommendations across multiple dimensions.

Return JSON:
{
  "overall_score": number,
  "overall_score_label": "Excellent|Good|Average|Needs Improvement",
  "summary": "2-3 sentence executive summary",
  "categories": [
    {
      "category": "Space Efficiency",
      "score": number,
      "recommendations": [
        {
          "priority": "high|medium|low",
          "title": "Recommendation title",
          "description": "Detailed description",
          "estimated_benefit": "Cost savings or improvement description",
          "implementation_difficulty": "easy|moderate|complex",
          "estimated_cost_impact": number,
          "roi_months": number
        }
      ]
    }
  ],
  "optimization_categories": [
    "Space Efficiency",
    "Energy Efficiency",
    "Cost Reduction",
    "Structural Integrity",
    "Natural Lighting",
    "Ventilation & Air Quality",
    "Sustainability",
    "Future-proofing",
    "Safety & Accessibility",
    "Aesthetic Improvements"
  ],
  "quick_wins": [
    {
      "title": "Quick win title",
      "description": "Brief description",
      "estimated_savings": number,
      "effort": "minimal|low|medium"
    }
  ],
  "energy_features": [
    {
      "feature": "Solar panels",
      "estimated_cost": number,
      "annual_savings": number,
      "payback_years": number,
      "feasibility": "high|medium|low",
      "notes": "context-specific notes"
    }
  ],
  "comparable_projects": {
    "average_cost_sqft_country": number,
    "your_estimate_sqft": number,
    "cost_efficiency": "above_average|average|below_average",
    "notes": "comparison notes"
  }
}`;

  const response = await callClaude(systemPrompt, userPrompt);
  const result = parseClaudeJSON(response);

  cache.set(cacheKey, result);
  return result;
};

module.exports = {
  generateFloorPlan,
  generateCostEstimate,
  generateMaterialReport,
  generateOptimizationSuggestions
};
