FROM ubuntu:jammy
#FROM fedora:36

RUN apt-get update && apt-get -y upgrade && apt-get -y install make wget git patch
#RUN dnf -y update && dnf -y install make wget git patch


# dependencies needed to run ./mach bootstrap
RUN ( apt-get -y update && apt-get -y upgrade && apt-get -y install python3 python3-dev python3-pip wget dpkg-sig ; true)
RUN ( dnf -y upgrade && dnf -y install python3 python3-devel wget rpm-build rpm-sign ; true)



WORKDIR /
RUN rm -rf /source
RUN git clone https://gitlab.com/librewolf-community/browser/source.git
WORKDIR /source

RUN make check && make setup-debian && make fetch && make bootstrap && make veryclean
#RUN make check && make setup-fedora && make fetch && make bootstrap && make veryclean
