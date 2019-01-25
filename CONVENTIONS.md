# Project Conventions

## Project structure

Avoid writing code that relies on a specific scene structure (like calling methods from a parent node or referencing parent nodes on a node path). A good reference for this is [GDQuest's system design and interactions guidelines](https://github.com/GDquest/kickstarter-quest-3/blob/master/docs/code-guidelines.md#system-design-and-interactions).

## Code style guide

Follow [GDScript's official style guide](http://docs.godotengine.org/en/latest/getting_started/scripting/gdscript/gdscript_styleguide.html).

### Order inside a .gd file

	tool
  
	extends
  
	class_name
  
	enum
  
	const
  
	export var
  
	var
  
	lifecycle functions
		_ready
		_input
		_unhandled_input
		_process
		_physics_process
    
	instance functions
  
	funcref callbacks
  
	signal callbacks
  
	setters/getters (in pairs if needed, setter before getter)
  
	static functions

## Naming conventions

### Directories
`lowercase-kebab-case`

### Files
- **Generic files:** `lowercase_snake_case.ext`
- **GDScript files:** `UpperCamelCase.gd`
- **Scene files:** `SameNameAsNode.tscn`

## Commit messages

Try to follow ["The seven rules of a great Git commit message"](https://chris.beams.io/posts/git-commit/#seven-rules).

- Separate subject from body with a blank line
- Limit the subject line to 50 characters
- Capitalize the subject line
- Do not end the subject line with a period
- Use the imperative mood in the subject line
- Wrap the body at 72 characters
- Use the body to explain what and why vs. how

The "subject" here means the first line in the commit message.

If the commit closes an issue, add the line `Fix #123` or `Closes #123` at the end of the body, on a line of its own.
If it closes more than one issue, add more lines with `Closes` keyword:

```
Do something

This is the explanation.

Closes #123
Closes #456
Fix #789
```

Use `Fix` if it's a bug, otherwise use `Closes`.
