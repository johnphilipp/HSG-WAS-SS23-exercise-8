# Exercise 8: Organized Agents

This repository contains a partial implementation of a [JaCaMo](https://github.com/jacamo-lang/jacamo) application where a BDI agents coordinate with each other to achieve common goals within an organization.

## Table of Contents
- [Project structure](#project-structure)
- [Task 1](#task-1)
- [Task 2](#task-2)
- [How to run the project](#how-to-run-the-project)
- [Test with the real PhantomX Reactor Robot Arm](#test-with-the-real-phantomx-reactor-robot-arm)

## Project structure
```bash
├── additional-resources
│   └── org-rules.asl # provided rules for reasoning on (part of) an organization. Available in https://github.com/moise-lang/moise/blob/master/src/main/resources/asl/org-rules.asl
├── src
│   ├── agt
│   │   ├── inc
│   │   │   └── skills.asl # provided plans for reacting to (some) organizational events.
│   │   ├── org_agent.asl # agent program of the organization agent that is responsible for initializing and managing a temperature monitoring organization
│   │   ├── sensing_agent.asl # agent program of the sensing agent that reads the temperature in the lab by using a weather station artifact
│   │   └── acting_agent.asl # agent program of the acting agent that manifests the temperature in the lab by using a robotic arm Thing artifact
│   ├── env
│   │    └── tools
│   │        ├── WeatherStation.java # artifact that can be used for monitoring the temperature via the Open-Meteo Weather Forecast API (https://open-meteo.com/en/docs)
│   │        └── Converter.java # artifact that can be used for rescaling values
│   └── org   
│       └── org-spec.xml # organization specification for monitoring the temperature in the lab
└── task.jcm # the configuration file of the JaCaMo application
```

## Task 1
Complete the implementation in [`org_agent.asl`](src/agt/org_agent.asl) so that it initializes an organization and its organizational artifacts within a workspace.
- HINTS:
  - The organization specification [org-spec.xml](src/org/org-spec.xml) specifies the organization that has to be initialized. Study the specification to understand the structure of the organization.
  - The [Section 2.14 of the CArtAgO By Example Guide](https://www.emse.fr/~boissier/enseignement/maop13/courses/cartagoByExamples.pdf) contains examples on how to use the operations `createWorkspace` and `joinWorkspace` for creating and joining workspaces.
  - The [documentation of the `ora4mas.nopl` package](https://moise.sourceforge.net/doc/api/ora4mas/nopl/package-summary.html) of the MOISE library contains the API descriptions of all the organizational artifacts that need to be initialized and used (including descriptions of their operations, observable properties, and observable events). 
  - The [documentation of the `stdlib` package](https://jason.sourceforge.net/api/jason/stdlib/package-summary.html) of the Jason library contains the specifications of useful internal actions for programming Jason agents.
  - The agent program [`org_agent.asl`](src/agt/org_agent.asl) contains a plan for reacting to the addition of the test-goal `?formationStatus(ok)`. By executing this plan, an agent waits until the formation of an organizational group is completed. The implementation of the plan uses the observable property `formationStatus` of the [`GroupBoard`](https://moise.sourceforge.net/doc/api/ora4mas/nopl/GroupBoard.html) organizational artifact.
  - The agent program [`org_agent.asl`](src/agt/org_agent.asl) contains a plan for reacting to the addition of the achievement-goal `!inspect(OrganizationalArtifactId)`. By executing this plan, the agent launches a console for you to inspect the organizational artifact identified by the `OrganizationalArtifactId`.  

## Task 2
Complete the implementations in [`sensing_agent.asl`](src/agt/sensing_agent.asl), [`org_agent.asl`](src/agt/org_agent.asl) and [`acting_agent.asl`](src/agt/acting_agent.asl) so that agents can reason on the specification and the state of organizations to adopt roles and achieve organizational goals.
- HINTS: 
  - You can enable any agent that reasons on the organization to use the set of inference rules provided in [`org-rules.asl`](additional-resources/org-rules.asl). Study the file, which provides useful rules that may contribute to the agents reasoning on the organization. To enable an agent to directly use any of the provided rules, include the statement `{include("\$moiseJar/asl/org-rules.asl")}` to the desired `.asl` file. 
  - Make sure that your agents observe (are focused on) your desired organizational artifacts. By observing the organizational artifacts, the agents' belief bases will include beliefs that may help with reasoning on the organization. You can inspect agents' belief bases by visiting http://localhost:3272/.

## How to run the project
You can run the project directly in Visual Studio Code or from the command line with Gradle 7.4.
- In VSCode:  Click on the Gradle Side Bar elephant icon, and navigate through `GRADLE PROJECTS` > `exercise-8` > `Tasks` > `jacamo` > `task`.
- On MacOS and Linux run the following command:
```shell
./gradlew task
```
- On Windows run the following command:
```shell
gradle.bat task
```

## Test with the real PhantomX Reactor Robot Arm
The application uses by default the robotic arm on dry-run to manifest the temperature (i.e. the `ThingArtifact` only prints the HTTP request to the robotic arm without executing the request). Follow these steps, if you want to test your application with the real [PhantomX Reactor Robot Arm](https://www.trossenrobotics.com/p/phantomx-ax-12-reactor-robot-arm.aspx) that is located at the Interactions lab:
- Register as an operator of the robotic arm using the [HTTP API](https://interactions-hsg.github.io/leubot/#/user/addUser) of the arm and your credentials, e.g.:
```
curl --verbose --location 'https://api.interactions.ics.unisg.ch/leubot1/v1.3.4/user' --header 'Content-Type: application/json' --header 'Authentication: f2a8969781d581d53f9661f9bf16c45b' --data-raw '{
    "name": "Danai V.",
    "email": "danai.vachtsevanou@unisg.ch"
}'
```
- The response to the above request should return a response with a `Location` header, for example: `Location: https://api.interactions.ics.unisg.ch/leubot1/v1.3.4/user/7c41d146cfd74ce06577abc7f18c1187`. There `7c41d146cfd74ce06577abc7f18c1187` is your new API key. 
- Copy & paste your API key to the body of the `manifest_temperature` plan of the [`acting_agent.asl`](src/agt/acting_agent.asl), so that the agent uses the arm as a registered operator.
- Finally, on the same plan, set the second initialization parameter for creating the `ThingArtifact` from `true` to `false`, so that the dry-run mode is deactivated.
- You can remotely observe the behavior of the robotic arm here: https://interactions.ics.unisg.ch/61-102/cam1/live-stream.
