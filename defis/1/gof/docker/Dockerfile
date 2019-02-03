FROM golang:1.10-alpine
RUN mkdir /app 
ADD . /app/ 
WORKDIR /app 
RUN ls 
RUN go build -o main . 
CMD ["/app/main", "formula.csv", "user.txt", "view0.csv", "changes.txt"]