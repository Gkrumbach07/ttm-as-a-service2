FROM centos/python-38-centos7 AS base

# Setup env
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1

FROM base AS python-deps

USER 0

RUN pip install pipenv

# Install python dependencies in /op/app-root/.venv
COPY Pipfile .
COPY Pipfile.lock .
# Need PIPENV_IGNORE_VIRTUALENVS because py38 is a venv in centos7
RUN mkdir .venv && PIPENV_IGNORE_VIRTUALENVS=1 PIPENV_VENV_IN_PROJECT=1 pipenv install --deploy

FROM base AS runtime

USER 0

COPY ./app /opt/app-root/src

COPY --from=python-deps /opt/app-root/src/.venv /opt/app-root/src/.venv

WORKDIR /opt/app-root/src

EXPOSE 5000

CMD source /opt/app-root/src/.venv/bin/activate && flask run