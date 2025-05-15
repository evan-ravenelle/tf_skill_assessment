# Multi-Cloud Terraform Assignment

## Overview

Your task is to design and implement a multi-cloud infrastructure using Terraform. You are provided with modules for deploying networking and containerized applications in AWS and Azure. Your primary responsibility is to create a root-level configuration (e.g. `main.tf`) that orchestrates these modules into a cohesive solution.

## Objectives

- **Networking:** Deploy a secure network across AWS and Azure and establish connectivity between the two via a VPN connection.
- **AWS Deployment:**  
  Use two AWS accounts:
  - A **Shared Services** account for central networking components, including a Transit Gateway and a dynamically created VPN endpoint.
  - A **Production** account for application hosting, where the VPC is attached to the Transit Gateway provided by the Shared Services account.
- **Azure Deployment:**  
  Create an Azure virtual network with dedicated subnets for container workloads and transit connectivity. Deploy networking resources in one resource group.
- **Container Deployment:**  
  Deploy a containerized application using the image `carrumhealth/helloworld:stable`:
  - On AWS (using ECS Fargate) in the production account.
  - On Azure (using Azure Container Instances with VNET integration) in a separate container resource group.

## Requirements

- **Terraform Infrastructure:**  
  - Use the provided modules for networking and container deployments.
  - Create a root-level configuration that integrates these modules, passing the necessary variables between them.
  - The Shared Services AWS module must create a Transit Gateway and a dynamic VPN endpoint.  
  - The VPN shared key should be retrieved from AWS Secrets Manager using a data source.
  - The Azure module should reference the AWS Production VPC CIDR dynamically rather than hardcoding it.
  - Azure resources must be deployed into dedicated resource groups:
    - Networking (VNET, subnets, VPN gateway/connection) in one resource group (e.g., `my-azure-network-rg`).
    - Container deployments in a separate resource group (e.g., `my-azure-container-rg`).

- **Architectural Diagram:**  
  In addition to your Terraform code, you must create a cloud architecture diagram that illustrates an ideal AWS & Azure design (can be different than what you developed above). The diagram should be exported as a PDF and include, at a minimum:
  - Key networking components (e.g., VPC/VNET, subnets, Transit Gateway, VPN endpoints/gateways)
  - Container deployment components (e.g., ECS/EKS in AWS, AKS in Azure)
  - An overview of connectivity between the AWS and Azure environments
  - Database layer
  - Any additional cloud services or components that you consider relevant to a robust multi-cloud deployment

## Deliverables

- A complete Terraform configuration that integrates the provided modules.
- A PDF architectural diagram that clearly depicts a multi-cloud design
- A README (this file) summarizing your approach, design decisions, and instructions for deployment.

## Summary

The provided modules didn't seem to contain the necessary resources to complete a connection between the two cloud environments to support a dynamic BGP connection between the two. I'm not sure if this was the expected or intended approach, but is the approach I took.  See the considerations section for details on what was added. 

Unfortunately, this created a circular dependency, which sometimes happens when you have two dependent resources that need information from each other that is not available until after provisioning.

Terraform works best when the dependency graph can be resolved in a single pass. Unfortunately, for some two-way configurations, dependencies cannot be resolved in a single execution and require some manual effort to complete the configuration.

In this case, both sides of the connection need the other side's public VPN IP to connect the network to the TGW. I wanted to ensure that this could be handled as simply as possible and, using Terraform's lazy evaluation of ternary operators, this can be 
mostly automated down to a single variable, `use_ip_placeholder.`

This could be handled in a more automated way in a pipeline environment using pipeline env vars to automate the process and prevent having to make manual changes to the vars file.

## Considerations

- As provided, the modules didn't seem to contain the necessary resources to complete a connection between the two cloud environments.  To complete the configuration, several resources were added to the AWS Networking module:
  - AWS Site-to-Site VPN Connection was added to create a connection between TGW and CGW
  - CGW was added to provide the public interface to the VPN from the Azure side
  - Added VPN Gateway Public IP output to Azure networking for use in AWS CGW
  - BGP IP addresses were assigned to interfaces to facilitate border gateway protocol connections
  - This configuration creates a circular dependency (necessary for two-way configuration)
    - AWS TGW needs the IP of the AZ VNET Gateway
    - AZ VNET Gateway needs the IP of the TGW public VPN
    - See deploy instructions for details
- IP subnet ranges were selected for expandability and to ensure enough IP space; without knowing the requirements of the application, it's difficult to estimate what this requirement could be so went with the middle-path 
- There are no route tables, SGs, or NACLs configured.  As I was running short on time I did not include these, but a proper solution should include these.

## Deploying
- 
- Set `use_ip_placeholder` to `true` in prod.tfvars
- Run `terraform plan -var-file=prod.tfvars -out "initial.plan" `
- Verify the plan output
- Run `terraform apply initial.plan`
- Wait for configurations to complete--AZ VNET gateway creation can take a long time
- When both are complete, change `use_bpg_placeholder` to `false` in prod.tfvars
- Run `terraform plan -var-file=prod.tfvars -out "update.plan" `
- Verify the plan output
- Run `terraform apply update.plan`
