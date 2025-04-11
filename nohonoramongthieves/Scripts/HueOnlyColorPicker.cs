using Godot;

public partial class HueOnlyColorPicker : ColorPickerButton
{
	private Color baseColor = new Color(1, 0, 0); // Default color (Red)

	public override void _Ready()
	{
		Color = baseColor; // Set default color
		Connect("color_changed", Callable.From<Color>(OnColorChanged));
	}

	private void OnColorChanged(Color newColor)
	{
		// Keep only the new hue but apply the original saturation and value
		float hue = newColor.H;
		float saturation = baseColor.S; // Lock saturation
		float value = baseColor.V; // Lock value

		// Create a new color with modified properties
		Color adjustedColor = Color.FromHsv(hue, saturation, value);
		
		// Prevent unwanted saturation/brightness changes
		Color = adjustedColor;
	}
}
