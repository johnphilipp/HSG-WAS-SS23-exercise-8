// acting agent

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://ci.mines-stetienne.fr/kg/ontology#PhantomX
robot_td("https://raw.githubusercontent.com/Interactions-HSG/example-tds/main/tds/leubot1.ttl").

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

+newOrg(WspName, OrgName, GoalToRecruitFor, RoleToRecruitFor) : true <-
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
 * Plan for reacting to the addition of the goal !manifest_temperature
 * Triggering event: addition of goal !manifest_temperature
 * Context: the agent believes that there is a temperature in Celcius and
 * that a WoT TD of an onto:PhantomX is located at Location
 * Body: converts the temperature from Celcius to binary degrees that are compatible with the 
 * movement of the robotic arm. Then, manifests the temperature with the robotic arm
*/
@manifest_temperature_plan 
+!manifest_temperature : temperature(Celcius) & robot_td(Location) <-
	.print("I will manifest the temperature: ", Celcius);
	makeArtifact("covnerter", "tools.Converter", [], ConverterId); // creates a converter artifact
	convert(Celcius, -20.00, 20.00, 200.00, 830.00, Degrees)[artifact_id(ConverterId)]; // converts Celcius to binary degress based on the input scale
	.print("Temperature Manifesting (moving robotic arm to): ", Degrees);

	/* 
	 * If you want to test with the real robotic arm, 
	 * follow the instructions here: https://github.com/HSG-WAS-SS23/exercise-8/blob/main/README.md#test-with-the-real-phantomx-reactor-robot-arm
	 */
	// creates a ThingArtifact based on the TD of the robotic arm
	makeArtifact("leubot1", "wot.ThingArtifact", [Location, true], Leubot1Id);
	
	// sets the API key for controlling the robotic arm as an authenticated user
	setAPIKey("4c001eb82c3c495a08bd7da8b48915bb")[artifact_id(leubot1)];

	// invokes the action onto:SetWristAngle for manifesting the temperature with the wrist of the robotic arm
	invokeAction("https://ci.mines-stetienne.fr/kg/ontology#SetWristAngle", ["https://www.w3.org/2019/wot/json-schema#IntegerSchema"], [Degrees])[artifact_id(leubot1)].

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }

/* Import behavior of agents that work in MOISE organizations */
{ include("$jacamoJar/templates/common-moise.asl") }

/* Import behavior of agents that reason on MOISE organizations */
{ include("$moiseJar/asl/org-rules.asl") }

/* Import behavior of agents that react to organizational events
(if observing, i.e. being focused on the appropriate organization artifacts) */
{ include("inc/skills.asl") }
