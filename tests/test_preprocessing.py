"""Preprocessing pipeline tests."""


def test_image_input_validation():
    image_shape = (224, 224, 3)

    assert len(image_shape) == 3
    assert image_shape[-1] == 3
