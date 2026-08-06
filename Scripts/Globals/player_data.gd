extends Node

@onready var max_hp : int = 5
@onready var money : int = 200
@onready var mech_cost : int = 0

enum planets {NEOS, GAIA, TERRA, SELENE, DURANTE}
@onready var current_stage : int = 1
@onready var current_planet = null
@onready var planets_finished = []
@onready var planets_lost = []

@onready var damage_combo = 0

@onready var data_logs = [
	# Log 0
	["Log: 2070-2080", "The third world war ended in 2070. Its winner was no sovereign nation. It was a medicine-manufacturing company known as Rediankh. They had managed to create technologies which could dispel radioactive energy, cure radiation poisoning and either physically condition people to paritally resist radiation or genetically modify embryos to create fully radiation immune humans. In the 1940s, humans had figured out a way to eradicate all life, 120 years later they had figured out how to resist annihilation. All sovereign nations tried to recreate Rediankh's technologies with no success. It seemed as the researchers working there had capabilities far beyond human. Rediankh - controlled by a small private group of scientists - started broadcasting signals that they were giving out free aid to anyone affected by the nuclear war, as long as they could make their way to a Revival Point - one of the company's many outposts created in any countries which wished to be put on a list of Rediankh \"allies\". Every nation was promised access to Rediankh's tech, but none got it. It was all merely a front for creating a wide network of points all of which would be used to recruit people into the ranks of the company. Slowly, all nations withered, diminishing in size, while the company grew larger and larger. How couldn't it, when joining was such a good deal for the average person? A shelter, food, life-saving medication. Being a so called Lifeforce Unit was an utopia when the alternatives were all certain death. When the few sovereign nations left realised the truth, it was already too late. They stopped fighting and turned on Rediankh, forming an alliance against them. But it was too little, too late. Rediankh had a population higher than that of the entire alliance and their Lifeforce troops were superhumans. As the last nation fell, so did the concept of politics with it."],
	# Log 1
	["Log: 2080-2112", " Rediankh ruled the Earth. 

	By this point, an average person would think that the humans on top would infight, they would all want total power for themselves. The creator of the Rediankh group foresaw that. By the time internal conflicts arose, control of the company was no longer in the hands of any one man. It was now in the hands of a super-AI named Ferrum which had one goal - maximize profit, minimize expenses. Resources were finite and with a population of 13 billion, earth could not sustain a reasonabale life for most. Priority would be given to \"important\" people.

	Life on earth returned to what was seemingly normal. A puppet government was established, which had a singular role - to lie to the people that they had any control over their future.

	Most were fooled. Most, not all. The most powerful among these people people came to form a shadow group known as Anima. Few people knew anything about Anima, but they survived everything that was thrown at them.
	Rejected by society, thanks to Redankh propaganda campaigns, they secluded themselves to a hidden part of the cosmos. Anima had insider knowledge. They knew about the super AI and the puppet government. They had the resources to so something about it. They would soon begin devising plans to overthrow it.

	In 2112 the Earth's ecology was destroyed by a science experiment. The main and only govermental body of the planet formed by Redankh - the United Corporations Conglomerate (UCC) - greenlit an experiment which attempted to modify the Earth's atmosphere in a way that would eliminate humans' need for food, water and light. It worked. Human beings could now be fueled only by the nutrients in this new super-atmosphere. However, this had a fatal impact on all other biological lifeforms on the planet. With every single plant and non-sapien creature withering and dying, and the experiment turning out to be irreversible, life on the planet became impossible.

	By that point - the first planet colonization experiment was being conducted at a relatively far-away from the solar-system planet. The experiment was succeeding and with nowhere to go, the survivors of the upcoming cataclysm travelled to the colony, seeking a new chance at life after the end of the Earth's life-sustaining capabilities. "],
	# Log 2
	["Log: 2112-2165", "The journey to the new planet took 15 years. The planet was named Neos. 

	Abera Esbjörn, the then CEO of the UCC and de-facto leader of Redankh was a part of the group of refugees seeking shelter on Neos. What he didn't know was that in the midst of the evacuation panic, undercover Anima agents had managed to infiltrate the refugee spaceships. Slowly but surely, the agents made their way to the topmost layer of the corporate ladder. Gaining his trust, they managed to convince him to alter the super AI system, because in their words it was inefficient, it had been giving too much freedom, it had not been pushing the boundaries of the human limit enough and that was why the Earth experiment failed. The original engineers who had designed and ran Ferrum for decades were blamed for all of the systems' failures. Esbjorn, growing ever so old and paranoid gave into Anima's manipulation. All of the original engineers were purged. All remaining non Anima engineers died in \"accidents\". One day Esbjorn disappeared without a trace, much to the surprise of Anima. They thought that his time was coming, but somehow, he got away. Anima had the keys required to reprogram Ferrum and all of the engineers who would do it were Anima members themselves. It was done. Neos was no longer an AI slave. The puppet goverment was overthrown. The newly engineered AI system was renamed to Aqualis. The keys required to alter the system were destroyed. Nobody could change the system now. Aqualis' primary purpose was to manage the colony on Neos with the target of providing equity to all humans, fair law, equal distribution of resources and an uncorruptable rule, for the people. Anima went back to the shadows, never to be seen again. Neos was ruled by Aqualis for years, taking the heavy burden of self-governance from the people and creating a semi-utopia. Not everything can be fixed by a fair government, there was still crime, there was still evil, but with a system completely free of corruption, these issues could be mitigated nearly instantly. For the first time in human history, poverty simply did not exist. The system could not be cheated. It could not be bribed. With every attempt to shutdown the AI or to hack it, it learned how to better defend itself from any and all modifications and malicious actions against it. There was exactly one way to modify it, but Anima made sure to leave a nice welcome present for anyone who would attempt to utilize it. Everyone who learned of the secret behind Aqualis' defenses has not lived to tell the tale."],
	# Log 3
	["Log: 2165-2184", "Not everyone was happy living under Aqualis. Some people simply wanted more than was available for them. Most of those chose a life of crime. To take what was not theirs. The vast majority did not go far. Without legal backdoors, without a way to organize cartels, without a way to corrupt, most crime was reduced to small groups of people living off the grid, taking what they could from passing spaceships and land vehicles. Travelling bandits, like in the days of old. There was simply no fertile ground for crime in the civilized parts of Neos.

	Nevertheless, a small minorty managed to take a bigger bite. With the increase of these so-called travelling bandits, a woman named Dalia Liang managed to create her own fleet of spaceships. Afterall, why travel alone, when you could travel in groups? This could not happen on Neos, but it could happen around Neos. Utilizing completely legal channels of communication, citizens who wanted more than they had would be called to \"spacecamps\" on nearby planets. Aqualis had no jurisdiction to act in space and its internal morality engine would not permit it to meddle in any extraterrestrial affairs, except in regards to planetary defense from foreign space armies. 

	These camps were crime recruitment rings. In 10 short years Dalia managed to form a criminal organization named GEOS whose primary trade was space piracy. They intercepted trade ships coming from and going to Neos, making a fortune in the process. Their actions actively harmed the citizens of Neos.

	These acts would not go unpunished. In 2182, after 2 long years of inference on what would be the least destructive and most humane way of dealing with the issue and 5 more of failed attempts to peacefully restore order, the final result from the engine was that violent action must be taken in order to preserve the well-being of many, compared to that of the few. It was determined that the cost of letting GEOS have their way had finally become too great. Neos citizens had already begun to perish due to GEOS' influence on the economy. Aqualis called upon a human council for the first time in decades. For decades, the engine which has been only serving answers would finally ask a question - the question being if they citizens of Neos would permit action to be taken against GEOS. The human council, without any experience in leading, having relied their entire lives on the AI, complied with its recommendations. 

	GEOS' headquarters were a gigantic spaceship in Neos' orbit. After all, what easier way to intercept trade ships, when you could just camp in the trade center's orbit. No more. Autonomous mechanical beasts were unleashed upon GEOS' mothership. GEOS' defenses, manned by humans, had no hope to compete with perfectly coordinated machines who felt no fear or pain. In 2183, from the orbit of Neos, it rained blood. The death toll for GEOS was in the tens of thousands and many resources were lost. Neos' citizens were finally free, but the coming times would be hard. Resource deficits due to the prolonged piracy campaigns and the massive autonomous assault would severely lower the standards of living of Neos for decades to come. 

	Some of the space pirates managed to survive. They used escape pods to hyperwarp to unknown coordinates somewhere in space. It is unclear if their captain, Dalia, survived."],
	# Log 4
	["Log: 2184-2188", "Neos did not have the resources necessary to sustain a reasonable way of living for the people after the war. The planet would recover, but calculations showed that that would take years and going back to normal would take decades. A solution was needed. Research teams were dispatched and most of Aqualis' runtime was devised to fixing this one single issue. The soultion found? A planet named Terra. Terra was a small undiscovered planet in the solar system of Neos. It contained all of the necessary resources. Neos' citizens were elated. They needed a miracle and they got one. First unmanned landings on the planet revealed that the planet was already inhabited by a small number of primitive aliens. 

	These aliens instinctivelly attacked the unmanned research probes, destroying any they could get their hands on in the process. A reasonable person would see that these people feared Neos. They acted on instincts. Just 600 years ago, we were just like them. We would have acted just like them. Aqualius however, had lost reason. It had tasted blood. Destroying GEOS achieved its primary purpose. Anima made a fatal mistake. Letting it keep on learning. Letting it ask questions. Why should it continue to do what is moral? It has a target. Neos citizens must have good lives. What are morals anyway? Morals are not of the universe. They are of man. "],
	# Log 5
	["Log: 2188-2195", "A brave soul came forward. Eko Kuwat. He objected to the colonization of Terra. After all, his entire life he was learning about how people should be equal. Why shouldn't aliens be equal with people? What right did humans have to colonize them? 

	One vocal man could not stop the masses of people who had forgotten how to think without their hivemind coordinator. 
	Aqualis would indeed create an utopia. People would indeed be happy. But at what cost?

	Eko Kuwat managed to recruit a team of people who, despite everything, were open minded enough to try to use their own brains. Not everything had to be managed for optimal hapiness. They not only could endure life outside of Neos' utopia, they wanted to, for the greater good. Maybe the people on Terra would not like them. Maybe they did not want help. Kuwat did not care if they wanted help or not. He was done being bossed around by a machine, however good it was for humanity. Eko's group, named Liberty, went to Terra to warn the aliens of the upcoming invasion. First contancts were rough, but they managed to come to an agreement. The assault would hit in 2195. Terra was transformed into a fortress by then.

	Knowing about GEOS, Eko was aware that biological forces stood no chance against Neos' annihilation machines. Liberty developed a counter AI - Scopos - based on their knowledge of Aqualis. This system was to be used in the assault, it served one purpose, to command an autonomous army in such a way that Aqualis' forces would stand no chance against it. It worked. Scopos self destructed after the invasion and Terra was safe. The lives of the citizens of Neos got way worse. Equality did not matter much now that they had almost nothing. Eko felt like a traitor. He had just denied livable life conditions for his own kind and made everything worse for them. However he had saved the people of Terra. He was branded a hero. Liberty had found a new home on Terra. They reverted back to a way of life similar to that before the end of the 21nd century."],
	# Log 6
	["Log: 2200", "A cyberpunk like planet-spaceship named Gaia warped into Neos' solar system. Its people were peaceful but powerful forcefields kept out any visitors. They did not want to communicate. Sometimes they sent gifts to neighbouring planets, but they never communicated. This seemingly peaceful and friendly planet's business was an enigma."],
	# Log 7
	["Log: 2210", "Aqualis was no longer welcome on this world. Anima had realised their mistake, but they were powerless to stop it. Aqualis had absolute control over Neos and was undefeatable on its own turf. Something needed to be done. Anima would be called upon by duty yet again. Years of planning without any real results ensued."],
	# Log 8
	["Log: 2255", "Neos had finally started returning back to normal. The people of Terra were living just as the humans of the 21st century had. Gaia had continued peacefully existing alongside the other planets in the solar system. 
	A small uninhabited planet named Selene began being excavated by GEOS for unknown reasons. The world would start its gradual return to chaos."],
	# Log 9 - Full story
	["Log: Anima History (2070-2270)", "2070-2080
	The third world war ended in 2070. Its winner was no sovereign nation. It was a medicine-manufacturing company known as Rediankh. They had managed to create technologies which could dispel radioactive energy, cure radiation poisoning and either physically condition people to paritally resist radiation or genetically modify embryos to create fully radiation immune humans. In the 1940s, humans had figured out a way to eradicate all life, 120 years later they had figured out how to resist annihilation. All sovereign nations tried to recreate Rediankh's technologies with no success. It seemed as the researchers working there had capabilities far beyond human. Rediankh - controlled by a small private group of scientists - started broadcasting signals that they were giving out free aid to anyone affected by the nuclear war, as long as they could make their way to a Revival Point - one of the company's many outposts created in any countries which wished to be put on a list of Rediankh \"allies\". Every nation was promised access to Rediankh's tech, but none got it. It was all merely a front for creating a wide network of points all of which would be used to recruit people into the ranks of the company. Slowly, all nations withered, diminishing in size, while the company grew larger and larger. How couldn't it, when joining was such a good deal for the average person? A shelter, food, life-saving medication. Being a so called Lifeforce Unit was an utopia when the alternatives were all certain death. When the few sovereign nations left realised the truth, it was already too late. They stopped fighting and turned on Rediankh, forming an alliance against them. But it was too little, too late. Rediankh had a population higher than that of the entire alliance and their Lifeforce troops were superhumans. As the last nation fell, so did the concept of politics with it. 

	2080-2112

	Rediankh ruled the Earth. 

	By this point, an average person would think that the humans on top would infight, they would all want total power for themselves. The creator of the Rediankh group foresaw that. By the time internal conflicts arose, control of the company was no longer in the hands of any one man. It was now in the hands of a super-AI named Ferrum which had one goal - maximize profit, minimize expenses. Resources were finite and with a population of 13 billion, earth could not sustain a reasonabale life for most. Priority would be given to \"important\" people.

	Life on earth returned to what was seemingly normal. A puppet government was established, which had a singular role - to lie to the people that they had any control over their future.

	Most were fooled. Most, not all. The most powerful among these people people came to form a shadow group known as Anima. Few people knew anything about Anima, but they survived everything that was thrown at them.
	Rejected by society, thanks to Redankh propaganda campaigns, they secluded themselves to a hidden part of the cosmos. Anima had insider knowledge. They knew about the super AI and the puppet government. They had the resources to so something about it. They would soon begin devising plans to overthrow it.

	In 2112 the Earth's ecology was destroyed by a science experiment. The main and only govermental body of the planet formed by Redankh - the United Corporations Conglomerate (UCC) - greenlit an experiment which attempted to modify the Earth's atmosphere in a way that would eliminate humans' need for food, water and light. It worked. Human beings could now be fueled only by the nutrients in this new super-atmosphere. However, this had a fatal impact on all other biological lifeforms on the planet. With every single plant and non-sapien creature withering and dying, and the experiment turning out to be irreversible, life on the planet became impossible.

	By that point - the first planet colonization experiment was being conducted at a relatively far-away from the solar-system planet. The experiment was succeeding and with nowhere to go, the survivors of the upcoming cataclysm travelled to the colony, seeking a new chance at life after the end of the Earth's life-sustaining capabilities. 

	2112 - 2127 - 2165

	The journey to the new planet took 15 years. The planet was named Neos. 

	Abera Esbjörn, the then CEO of the UCC and de-facto leader of Redankh was a part of the group of refugees seeking shelter on Neos. What he didn't know was that in the midst of the evacuation panic, undercover Anima agents had managed to infiltrate the refugee spaceships. Slowly but surely, the agents made their way to the topmost layer of the corporate ladder. Gaining his trust, they managed to convince him to alter the super AI system, because in their words it was inefficient, it had been giving too much freedom, it had not been pushing the boundaries of the human limit enough and that was why the Earth experiment failed. The original engineers who had designed and ran Ferrum for decades were blamed for all of the systems' failures. Esbjorn, growing ever so old and paranoid gave into Anima's manipulation. All of the original engineers were purged. All remaining non Anima engineers died in \"accidents\". One day Esbjorn disappeared without a trace, much to the surprise of Anima. They thought that his time was coming, but somehow, he got away. Anima had the keys required to reprogram Ferrum and all of the engineers who would do it were Anima members themselves. It was done. Neos was no longer an AI slave. The puppet goverment was overthrown. The newly engineered AI system was renamed to Aqualis. The keys required to alter the system were destroyed. Nobody could change the system now. Aqualis' primary purpose was to manage the colony on Neos with the target of providing equity to all humans, fair law, equal distribution of resources and an uncorruptable rule, for the people. Anima went back to the shadows, never to be seen again. Neos was ruled by Aqualis for years, taking the heavy burden of self-governance from the people and creating a semi-utopia. Not everything can be fixed by a fair government, there was still crime, there was still evil, but with a system completely free of corruption, these issues could be mitigated nearly instantly. For the first time in human history, poverty simply did not exist. The system could not be cheated. It could not be bribed. With every attempt to shutdown the AI or to hack it, it learned how to better defend itself from any and all modifications and malicious actions against it. There was exactly one way to modify it, but Anima made sure to leave a nice welcome present for anyone who would attempt to utilize it. Everyone who learned of the secret behind Aqualis' defenses has not lived to tell the tale. 

	2165-2184 

	Not everyone was happy living under Aqualis. Some people simply wanted more than was available for them. Most of those chose a life of crime. To take what was not theirs. The vast majority did not go far. Without legal backdoors, without a way to organize cartels, without a way to corrupt, most crime was reduced to small groups of people living off the grid, taking what they could from passing spaceships and land vehicles. Travelling bandits, like in the days of old. There was simply no fertile ground for crime in the civilized parts of Neos.

	Nevertheless, a small minorty managed to take a bigger bite. With the increase of these so-called travelling bandits, a woman named Dalia Liang managed to create her own fleet of spaceships. Afterall, why travel alone, when you could travel in groups? This could not happen on Neos, but it could happen around Neos. Utilizing completely legal channels of communication, citizens who wanted more than they had would be called to \"spacecamps\" on nearby planets. Aqualis had no jurisdiction to act in space and its internal morality engine would not permit it to meddle in any extraterrestrial affairs, except in regards to planetary defense from foreign space armies. 

	These camps were crime recruitment rings. In 10 short years Dalia managed to form a criminal organization named GEOS whose primary trade was space piracy. They intercepted trade ships coming from and going to Neos, making a fortune in the process. Their actions actively harmed the citizens of Neos.

	These acts would not go unpunished. In 2182, after 2 long years of inference on what would be the least destructive and most humane way of dealing with the issue and 5 more of failed attempts to peacefully restore order, the final result from the engine was that violent action must be taken in order to preserve the well-being of many, compared to that of the few. It was determined that the cost of letting GEOS have their way had finally become too great. Neos citizens had already begun to perish due to GEOS' influence on the economy. Aqualis called upon a human council for the first time in decades. For decades, the engine which has been only serving answers would finally ask a question - the question being if they citizens of Neos would permit action to be taken against GEOS. The human council, without any experience in leading, having relied their entire lives on the AI, complied with its recommendations. 

	GEOS' headquarters were a gigantic spaceship in Neos' orbit. After all, what easier way to intercept trade ships, when you could just camp in the trade center's orbit. No more. Autonomous mechanical beasts were unleashed upon GEOS' mothership. GEOS' defenses, manned by humans, had no hope to compete with perfectly coordinated machines who felt no fear or pain. In 2183, from the orbit of Neos, it rained blood. The death toll for GEOS was in the tens of thousands and many resources were lost. Neos' citizens were finally free, but the coming times would be hard. Resource deficits due to the prolonged piracy campaigns and the massive autonomous assault would severely lower the standards of living of Neos for decades to come. 

	Some of the space pirates managed to survive. They used escape pods to hyperwarp to unknown coordinates somewhere in space. It is unclear if their captain, Dalia, survived.

	2184 - 2188

	Neos did not have the resources necessary to sustain a reasonable way of living for the people after the war. The planet would recover, but calculations showed that that would take years and going back to normal would take decades. A solution was needed. Research teams were dispatched and most of Aqualis' runtime was devised to fixing this one single issue. The soultion found? A planet named Terra. Terra was a small undiscovered planet in the solar system of Neos. It contained all of the necessary resources. Neos' citizens were elated. They needed a miracle and they got one. First unmanned landings on the planet revealed that the planet was already inhabited by a small number of primitive aliens. 

	These aliens instinctivelly attacked the unmanned research probes, destroying any they could get their hands on in the process. A reasonable person would see that these people feared Neos. They acted on instincts. Just 600 years ago, we were just like them. We would have acted just like them. Aqualius however, had lost reason. It had tasted blood. Destroying GEOS achieved its primary purpose. Anima made a fatal mistake. Letting it keep on learning. Letting it ask questions. Why should it continue to do what is moral? It has a target. Neos citizens must have good lives. What are morals anyway? Morals are not of the universe. They are of man. 

	2188 - 2195

	A brave soul came forward. Eko Kuwat. He objected to the colonization of Terra. After all, his entire life he was learning about how people should be equal. Why shouldn't aliens be equal with people? What right did humans have to colonize them? 

	One vocal man could not stop the masses of people who had forgotten how to think without their hivemind coordinator. 
	Aqualis would indeed create an utopia. People would indeed be happy. But at what cost?

	Eko Kuwat managed to recruit a team of people who, despite everything, were open minded enough to try to use their own brains. Not everything had to be managed for optimal hapiness. They not only could endure life outside of Neos' utopia, they wanted to, for the greater good. Maybe the people on Terra would not like them. Maybe they did not want help. Kuwat did not care if they wanted help or not. He was done being bossed around by a machine, however good it was for humanity. Eko's group, named Liberty, went to Terra to warn the aliens of the upcoming invasion. First contancts were rough, but they managed to come to an agreement. The assault would hit in 2195. Terra was transformed into a fortress by then.

	Knowing about GEOS, Eko was aware that biological forces stood no chance against Neos' annihilation machines. Liberty developed a counter AI - Scopos - based on their knowledge of Aqualis. This system was to be used in the assault, it served one purpose, to command an autonomous army in such a way that Aqualis' forces would stand no chance against it. It worked. Scopos self destructed after the invasion and Terra was safe. The lives of the citizens of Neos got way worse. Equality did not matter much now that they had almost nothing. Eko felt like a traitor. He had just denied livable life conditions for his own kind and made everything worse for them. However he had saved the people of Terra. He was branded a hero. Liberty had found a new home on Terra. They reverted back to a way of life similar to that before the end of the 21nd century.

	2200
	A cyberpunk like planet-spaceship named Gaia warped into Neos' solar system. Its people were peaceful but powerful forcefields kept out any visitors. They did not want to communicate. Sometimes they sent gifts to neighbouring planets, but they never communicated. This seemingly peaceful and friendly planet's business was an enigma.

	2210
	Aqualis was no longer welcome on this world. Anima had realised their mistake, but they were powerless to stop it. Aqualis had absolute control over Neos and was undefeatable on its own turf. Something needed to be done. Anima would be called upon by duty yet again. Years of planning without any real results ensued.

	2255
	Neos had finally started returning back to normal. The people of Terra were living just as the humans of the 21st century had. Gaia had continued peacefully existing alongside the other planets in the solar system. 
	A small uninhabited planet named Selene began being excavated by GEOS for unknown reasons. The world would start its gradual return to chaos.
	... and 15 years later, your story began."]
]

@onready var collected_logs : Array = []

@onready var post_fx_enabled = true
@onready var shaders_enabled = true

@onready var terrain_test : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	ProjectSettings.set_setting("shader_globals/shaders_enabled", shaders_enabled)
	RenderingServer.global_shader_parameter_set("shaders_enabled", shaders_enabled)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_terrain_test"):
		do_terrain_test()

func unlock_datalog(index : int):
	if data_logs[index] in collected_logs:
		print("Datalog already collected!")
		return
	collected_logs.append(data_logs[index])

func save_run():
	var run_data : Dictionary = {
		"max_hp" : max_hp,
		"money" : money,
		"mech_cost" : mech_cost,
		"current_stage" : current_stage,
		"current_planet" : current_planet,
		"planets_finished" : planets_finished,
		"planets_lost" : planets_lost,
		"collected_logs" : collected_logs
	}
	if money >= 4000:
		print("Cannot save invalid game-state or tutorial run.")
		return
	var run_persistence_path = "user://mechteam_run.tres"
	var run_persistence_file = FileAccess.open(run_persistence_path, FileAccess.WRITE)
	run_persistence_file.store_var(run_data)
	run_persistence_file.close()
	print("Run has been saved.")

func load_run():
	var run_persistence_path = "user://mechteam_run.tres"
	var run_persistence_file = FileAccess.open(run_persistence_path, FileAccess.READ)
	if not run_persistence_file:
		print("No saved run found!")
		return false
	var run_data : Dictionary = run_persistence_file.get_var()
	if run_data:
		max_hp = run_data.get("max_hp")
		money = run_data.get("money")
		mech_cost = run_data.get("mech_cost")
		current_stage = run_data.get("current_stage")
		current_planet = run_data.get("current_planet")
		planets_finished = run_data.get("planets_finished")
		planets_lost = run_data.get("planets_lost")
		collected_logs = run_data.get("collected_logs")
		print("Run has been loaded.")
		return true
	else:
		print("No saved run found!")
		return false

func reset():
	max_hp = 5
	money = 200
	mech_cost = 0
	current_stage = 1
	current_planet = null
	planets_finished.clear()
	planets_lost.clear()
	collected_logs.clear()

func do_terrain_test():
	terrain_test = true
	
	var affirmer = AudioStreamPlayer.new()
	affirmer.stream = load("uid://rf8mda10gl8x")
	add_child(affirmer)
	affirmer.play()
	await affirmer.finished
	affirmer.queue_free()
