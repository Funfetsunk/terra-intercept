extends DialogueEntry
class_name TutorialBeat

enum Action { MOVEMENT, FIRING, PICKUP_AND_TECH, FOCUS, ORDNANCE, SPECIAL }

@export var action: Action = Action.MOVEMENT
