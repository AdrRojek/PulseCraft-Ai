def test_form_score_module_importable():
    from ml.models.form_score import FormScoreRegressor
    m = FormScoreRegressor(in_dim=16)
    assert m is not None
