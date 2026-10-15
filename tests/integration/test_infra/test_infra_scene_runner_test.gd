## Example integration suite (/test-setup, 2026-10-16).
## Verifies ADR-0006's open item: gdUnit4's scene_runner accepts an instance
## that was already set up, so `setup(services)` runs before `_ready`.
extends GdUnitTestSuite

const SetupProbe := preload("res://tests/integration/test_infra/fixtures/setup_probe.gd")


func test_scene_runner_with_set_up_instance_sees_dependency_in_ready() -> void:
	# Arrange
	# auto_free: scene_runner frees only scenes it loaded by path, not instances
	var probe: Node = auto_free(SetupProbe.new())
	var dependency := RefCounted.new()
	probe.setup(dependency)

	# Act — scene_runner adds the instance to the tree, which runs _ready
	var runner := scene_runner(probe)
	await runner.simulate_frames(1)

	# Assert
	assert_bool(probe.ready_saw_dependency).is_true()
	assert_object(probe.dependency).is_same(dependency)
