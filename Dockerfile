FROM scratch
WORKDIR /app
COPY bareiron /app/bareiron
EXPOSE 25565
CMD ["/app/bareiron"]