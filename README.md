# TapestryAlgorithm
Implementation of Tapestry, which is a infrast for generic decentralized object location and routing applications programming interface based on a self-repairing, soft-state-based routing layer.

**PROJECT DESCRIPTION :**
An overlay network is a telecommunications network that is built on top of another network and is supported by its infrastructure. An overlay network decouples network services from the underlying infrastructure by encapsulating one packet inside of another packet. This is a implementation for one such overlay network architecture, known as Tapestry. Originally proposed in the paper "B. Y. Zhao, Ling Huang, J. Stribling, S. C. Rhea, A. D. Joseph and J. D. Kubiatowicz, "Tapestry: a resilient global-scale overlay for service deployment," in IEEE Journal on Selected Areas in Communications, vol. 22, no. 1, pp. 41-53, Jan. 2004, doi: 10.1109/JSAC.2003.818784.". 

Project is in the form of service oriented architecture, where Tapestry services are exposed as API's to underlaying network infrastructure which is established by exploiting the actor model facilities of Elixir Language. The API provides a Distributed Hashing Table, routing and multicasting infrastructure. Objects are published and unpublished using casting API's in multicasting infrastructure. In this project we have implemented the underlying network on top of which we have also implemented Tapestry infrastructure.

**STEPS TO RUN :**
