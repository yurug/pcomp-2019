FROM golang:1.11-alpine3.7
WORKDIR /usr/local/go/src
RUN mkdir -p /usr/local/go/src/github.com/yurug/pcomp-2019/defis/2/gof 
ADD . /usr/local/go/src/github.com/yurug/pcomp-2019/defis/2/gof/ 
WORKDIR /usr/local/go/src/github.com/yurug/pcomp-2019/defis/2/gof
RUN ls 
RUN go build -o ws