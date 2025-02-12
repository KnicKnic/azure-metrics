# Start from the sdk image
FROM mcr.microsoft.com/dotnet/sdk:7.0.201-cbl-mariner2.0@sha256:028affe744bded28ecdb10f9cc72c74c7abb961cfe5b89921c6c76daa21b596d AS build
ARG workingDir="/app"

WORKDIR "$workingDir"
COPY . $workingDir

RUN set -x && dotnet build metrics.sln -c "Release" -o "/build"


# Use the SDK image to create the nonroot user and group
FROM mcr.microsoft.com/dotnet/aspnet:8.0.13-cbl-mariner2.0-amd64@sha256:65177fbb224fde6b14186d5a1fd39607bdc3919e98b7efd9c194afa1be2d5955 AS users
RUN tdnf install shadow-utils -y && \
  tdnf clean all

RUN groupadd nonroot -g 1000 && useradd -r -M -s /sbin/nologin -g nonroot -c nonroot nonroot -u 1000

FROM scratch AS nonroot
COPY --from=users /etc/group /etc/group
COPY --from=users /etc/passwd /etc/passwd

# Copy the published application
FROM mcr.microsoft.com/dotnet/aspnet:8.0.13-cbl-mariner2.0-amd64@sha256:65177fbb224fde6b14186d5a1fd39607bdc3919e98b7efd9c194afa1be2d5955 AS runtime

COPY --from=nonroot / /

# if someone doesnt clean first installs may fail, so for a clean for people incase they forgot
RUN tdnf clean all && tdnf repolist --refresh && tdnf update -y && tdnf clean all

# curl for testing, tar for support of kubectl
RUN tdnf install curl tar -y && \
  tdnf clean all

# region switch to using ubuntu

# FROM mcr.microsoft.com/dotnet/aspnet AS runtime
# RUN apt-get update && apt-get install curl -y 
# RUN curl -sL https://aka.ms/InstallAzureCLIDeb |  bash

# endregion

# Set the working directory and copy the build
WORKDIR /app
COPY --from=build /build .

ENTRYPOINT ["dotnet", "/app/metrics.dll"]

EXPOSE 8080
USER nonroot