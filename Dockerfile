# Start from the sdk image
FROM mcr.microsoft.com/dotnet/sdk:6.0.402-cbl-mariner2.0@sha256:6b191af1c22feace2986b7322492525dc51eed9cf60e51b1764d14c4993b9c74 AS build
ARG workingDir="/app"

WORKDIR "$workingDir"
COPY . $workingDir

RUN set -x && dotnet build metrics.sln -c "Release" -o "/build"


# Use the SDK image to create the nonroot user and group
FROM mcr.microsoft.com/dotnet/aspnet:6.0.10-cbl-mariner2.0-amd64@sha256:8c13ec464efd47bf3b8bb84d1605301bc467d5008261f9acc0bb29366c933a33 AS users
RUN tdnf install shadow-utils -y && \
  tdnf clean all

RUN groupadd nonroot -g 1000 && useradd -r -M -s /sbin/nologin -g nonroot -c nonroot nonroot -u 1000

FROM scratch AS nonroot
COPY --from=users /etc/group /etc/group
COPY --from=users /etc/passwd /etc/passwd

# Copy the published application
FROM mcr.microsoft.com/dotnet/aspnet:6.0.10-cbl-mariner2.0-amd64@sha256:8c13ec464efd47bf3b8bb84d1605301bc467d5008261f9acc0bb29366c933a33 AS runtime

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