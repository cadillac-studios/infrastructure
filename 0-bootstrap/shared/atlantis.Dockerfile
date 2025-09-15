FROM ghcr.io/runatlantis/atlantis:dev-alpine-6c12919
COPY --from=gcr.io/google.com/cloudsdktool/google-cloud-cli:518.0.0-alpine /google-cloud-sdk /google-cloud-sdk

# Add gcloud to the PATH
ENV PATH=$PATH:/google-cloud-sdk/bin

USER root
# Need root user to install packages
RUN apk --no-cache add python3=~3.12
USER atlantis

RUN gcloud config set component_manager/disable_update_check true && gcloud config set metrics/environment github_docker_image