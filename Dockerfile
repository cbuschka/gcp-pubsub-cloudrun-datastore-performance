FROM python:3.9-slim-buster

ENV PYTHONPATH=/home/app
RUN useradd app -m -d /home/app
USER app
WORKDIR /home/app
ADD --chown=app:app /requirements.txt /home/app/
ENV PATH=$PATH:/home/app/.local/bin
RUN pip install --user -r requirements.txt
ADD --chown=app:app /app /home/app/app/
EXPOSE 8080

CMD [ "python3", "-B", "app" ]
