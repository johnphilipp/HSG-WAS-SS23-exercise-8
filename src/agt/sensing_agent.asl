// sensing agent


/* Initial beliefs and rules */
role_goal(R, G) :- role_mission(R, _, M) & mission_goal(M, G).
goal_feasible(G) :- .relevant_plans({+!G[scheme(_)]}, LP) & LP \== [].

/* Initial goals */
!start. // the agent has the goal to start

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agent believes that it can manage a group and a scheme in an organization
 * Body: greets the user
*/
@start_plan
+!start : true <-
	.print("Hello world").

+newOrg(WspName, OrgName) : true <-
  // join org
  joinWorkspace(WspName, WspId);

  // focus on org and its artifacts
  lookupArtifact(OrgName, OrgArtId);
  focus(OrgArtId);

  // focus on role and goal to recruit for
  !focusAgent;

  // adopt role
  !can_achieve.

 +!focusAgent : group(GroupName, _, _) & scheme(SchemeName, _, _) <-
	lookupArtifact(GroupName, GroupId);
	lookupArtifact(SchemeName, SchemeId);
	focus(GroupId);
	focus(SchemeId);
	.print("focusing on: ", GroupName, " and ", SchemeName).

+!can_achieve : role_goal(R, G) & goal_feasible(G) <-
    .print("can achieve: ", G, " with role: ", R);
	adoptRole(R);
	.print("adopted: ", R).

/* 
 * Plan for reacting to the addition of the goal !read_temperature
 * Triggering event: addition of goal !read_temperature
 * Context: true (the plan is always applicable)
 * Body: reads the temperature using a weather station artifact and broadcasts the reading
*/
@read_temperature_plan
+!read_temperature : true <-
	.print("I will read the temperature");
	makeArtifact("weatherStation", "tools.WeatherStation", [], WeatherStationId); // creates a weather station artifact
	focus(WeatherStationId); // focuses on the weather station artifact
	readCurrentTemperature(37.7749, 122.4194, Celcius); // reads the current temperature using the artifact
	.print("Temperature Reading (Celcius): ", Celcius);
	.broadcast(tell, temperature(Celcius)). // broadcasts the temperature reading

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }

/* Import behavior of agents that work in MOISE organizations */
{ include("$jacamoJar/templates/common-moise.asl") }

/* Import behavior of agents that reason on MOISE organizations */
{ include("$moiseJar/asl/org-rules.asl") }

/* Import behavior of agents that react to organizational events
(if observing, i.e. being focused on the appropriate organization artifacts) */
{ include("inc/skills.asl") }