Cazton : Microservices Training 

# Orchestration


## Terraform

[Terraform](https://www.terraform.io) cloud deployment configurations are provided:

- AWS
- AWS (Segmented Work Network)
- Azure

## Provisioning

Several [Helm](https://github.com/kubernetes/helm) charts have been included to provide a baseline deployment of your cluster. The *project-tasks* script provides a simple entry-point for deploying and removing each service.

See [Provisioning](./provision/README.md) for more info.


## Charts

Helm charts are provided for wrapping dotnet core microservices:

- Dotnet Core Service (dnc-service)
- Dotnet Core Worker (dnc-worker)

