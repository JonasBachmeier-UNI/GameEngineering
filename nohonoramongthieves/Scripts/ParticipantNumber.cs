using Godot;
using System;

public partial class ParticipantNumber : Node
{
	private LineEdit _participantNumberInput;
	private Button _submitButton;
	
	public override void _Ready()
	{
		_participantNumberInput = GetNode<VBoxContainer>("VBoxContainer").GetNode<LineEdit>("LineEdit");
		_submitButton = GetNode<VBoxContainer>("VBoxContainer").GetNode<Button>("Button");
		

		_submitButton.Pressed += OnSubmitButtonPressed;

		_participantNumberInput.TextSubmitted += OnTextSubmitted;
	}
	
	private void OnSubmitButtonPressed()
	{
		SubmitParticipantNumber();
		
	}
	
	private void OnTextSubmitted(string text)
	{
		SubmitParticipantNumber();
	}
	
	private void SubmitParticipantNumber()
	{
		string inputText = _participantNumberInput.Text.Trim();
		int participantNumber = int.Parse(inputText);
		
		var logger = (GodotObject)GetNode("/root/Logger");
		logger.Call("print_participant", participantNumber);
		
		SceneManager.Instance.SetParticipantNumber(participantNumber);
	}
}
