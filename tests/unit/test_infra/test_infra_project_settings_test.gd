## Example unit suite for the test infrastructure (/test-setup, 2026-10-16).
## Also guards ADR-0006 rule 4: the project registers no autoloads, and
## installing gdUnit4 must not add one.
extends GdUnitTestSuite


func test_project_settings_have_no_autoloads() -> void:
	# Arrange
	var autoloads: Array[String] = []

	# Act
	for property: Dictionary in ProjectSettings.get_property_list():
		var property_name: String = property["name"]
		if property_name.begins_with("autoload/"):
			autoloads.append(property_name)

	# Assert
	assert_array(autoloads).is_empty()


func test_engine_version_matches_the_pin() -> void:
	# Arrange
	var info: Dictionary = Engine.get_version_info()

	# Act
	var version := "%d.%d.%d" % [info["major"], info["minor"], info["patch"]]

	# Assert — docs/engine-reference/godot/VERSION.md pins 4.7.2
	assert_str(version).is_equal("4.7.2")
