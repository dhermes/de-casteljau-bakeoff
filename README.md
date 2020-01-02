# de Casteljau Bakeoff

> Experimenting with competing implementations for simultaneous
> B&#XE9;zier Curve evaluation

## Run Notebook Server

```
python -m pip install --upgrade pip virtualenv
python -m virtualenv --python=python3.7 .venv
.venv/bin/python -m pip install --requirement requirements.txt
.venv/bin/jupyter notebook
```

## Requirements

To update

```
python -m pip install --upgrade pip-tools  # For `pip-compile`
pip-compile --generate-hashes --output-file=requirements.txt requirements.txt.in
```
