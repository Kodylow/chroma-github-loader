# Replit Template: Chroma

[Chroma](docs.trychroma.com) is a simple way to 'plug' knowledge into large language models (LLMs) like GPT, letting them work with private data, new data that wasn't available at training time, or highly specialized data like medical or legal documents.

## The problem

ChatGPT and other large language models (LLMs) are very powerful general-knowledge, general-purpose AI systems, trained on vast amounts of publicly available data. 

But what if you want them to work with data they haven't seen in training? Things like your emails and personal notes, or news stories from after the training date?

LLMs also tend to hallucinate, making things up when they don't have the relevant knowledge. This can be a serious problem when working with specialized or highly technical topics, when the hallucination might also be difficult to detect.

## The solution - Pluggable knowledge

To solve these problems, we can 'plug' knowledge into an LLM, using a technique called 'retrieval'. At a high level, retrieval with LLMs works like this:

- Data is sent to an embeddings store, where it's encoded using an embedding model. Embeddings are a numerical representation of all kinds of data, and a natural way to represent data for AI applications. You can [Learn more about embeddings here](https://openai.com/blog/introducing-text-and-code-embeddings). 
- Queries are sent to the embedding store, where they are embedded and the most relevant results are returned.
- The model is prompted using the query, together with the relevant returned results.

This template gives you everything you need to create this workflow with [Chroma](docs.trychroma.com).

## Demo

The demo in [`main.py`](main.py) shows an example workflow, doing question answering on a [popular AI textbook](https://people.engr.tamu.edu/guni/csce421/files/AI_Russell_Norvig.pdf). Let's break it down step by step.

**Important**: For this demo to work, you will need an [OpenAI API Key](https://platform.openai.com/account/api-keys), since we use the OpenAI models. Once you have the key, set it as `OPENAI_API_KEY` in the Secrets tool. 

```python
collection = get_collection()
```

The function `get_collection()` shows how to instantiate a Chroma client which reads from a local persisted directory. For convenience, we're already stored the textbook, embedded by page. Each query will return the most relevant several pages of the textbook. 

> ### Using your own data {#using-your-own-data}
> 
> You can easily create and populate your own collections with Chroma, using any text data. We provide [a script](embed_data.py) which does this for you from a directory containing text files. Upload a directory containing tesxt files, then in the shell, run
>
>```bash
>python embed_data.py --data_directory <YOUR DATA DIRECTORY> --persist_directory <A DIRECTORY TO PERSIST CHROMA DATA> --collection_name <A NAME FOR YOUR COLLECTION>
>```
>to get your data into Chroma. For more, check out the [Chroma documentation](docs.trychroma.com).
>Change the `persist_directory` and `collection_name` arguments in `get_collection` to use your data in the demo.

```python
openai.api_key = os.environ['OPENAI_API_KEY']
```

We set the OpenAI API key. We'll be calling the chat completion endpoint. 

```python
query = input("Query: ")
if len(query) == 0:
  print("Please enter a question. Ctrl+C to Quit.\n")
  continue
print('\n')
```

In the input loop, we grab the user's query. Empty queries are escaped. 

```python
results = collection.query(query_texts=[query],
                           n_results=5,
                           include=['documents', 'metadatas'])
```

We query the Chroma collection, grabbing the 5 most relevant documents. These are returned in order from most to least relevant. We return the documents themselves, as well as the associated metadata - in this case, the page numbers associated with each returned document.

```python
contexts, sources = filter_results(results, MAX_PROMPT_LENGTH)
```

The OpenAI chat completions model only allows a finite prompt length. To make sure the returned documents fit, we drop the least relevant documents that don't fit. 

```python
response = get_chatGPT_response(query, contexts)
```

We prompt the model with the query, and the contexts, get its response, and print it to the console. 


### Example Output

Let's learn about AI from this popular textbook.

> Query: What can you tell me about intelligent agents?
> 
> 
> Intelligent agents are a central concept in the field of artificial intelligence. A rational agent is one that behaves as well as possible in any environment, with the concept of rationality applied to a wide variety of agents operating in any imaginable environment. Agents are anything that can be viewed as perceiving their environment through sensors and acting upon the environment through actuators. The observation that some agents behave better than others leads naturally to the idea of a rational agent. This behavior will depend on the nature of the environment, as some environments are more challenging than others.
>
> An agent's percept is its perceptual inputs at any given instant, with the percept sequence being the complete history of everything the agent has ever perceived. An agent's choice of action at any given time can depend on the entire percepts observed to date, but not on anything it hasn't perceived. Agents can combine and recombine information to suit myriad purposes by utilizing logic as a general class of representations to support knowledge-based agents.
>
> In the field of autonomous agents and multi-agent systems, it is common to design the agent program of a single agent as a collection of autonomous sub-agents that share no internal state and communicate with each other only through the environment. The goal-based view of agents dominates both the cognitive psychology tradition in the area of problem-solving and the field of multi-agent systems. The idea of intelligent agents has become increasingly important with the rise of internet and mobile softbots.
> Source pages: [52, 252, 1039, 79, 78]

Interesting, let's drill down a learn more about "Knowledge-based agents".

> Query: Tell me more about knowlege based agents.
>
>
>Knowledge-based agents are designed to be able to make use of knowledge to perform tasks. The central component of such an agent is its knowledge base, made up of a set of sentences expressed in a knowledge representation language that represents some assertion about the world. Knowledge acquisition is the process of assembling the relevant knowledge for a particular domain, often with the help of real experts. The agent is then able to use its inference mechanisms, such as TELL and ASK, to reason about the current state of the world and execute actions. 
>
>The representation language is usually hidden inside three functions that implement the interface between sensors and actuators on one side, and the core representation and reasoning system on the other. The agent's knowledge base may initially contain some background knowledge, which can be updated as new knowledge is acquired. 
>
>In terms of first-order logic, an agent can use logical inference with axioms to keep track of aspects of the world that are not directly observed. This is particularly useful in partially observable environments, where an agent's representation of what it knows about the current state is limited. Representing states as assignments of values to variables enables more efficient algorithms and domain-independent work. 
>
>Ontological engineering is the process of creating general and flexible representations of abstract concepts, which are useful in many different domains. These concepts include events, time, physical objects, and beliefs, and their representation is essential to connect problem instances to answers. Agents such as those used in internet shopping environments require procedural attachment, whereby particular predicates and functions can be handled by special-purpose methods. 
>
>To compare offers in an internet shopping environment, the agent must extract relevant information using wrappers. Information extraction from real web pages can be challenging, so a hierarchy of wrappers can be applied to a page, starting with a general one and moving to more specific ones that know the format of a particular store. Finally, a set of logical assertions is generated to represent the extracted information.
>Source pages: [253, 252, 325, 455, 484]

It seems like the way abstract concepts are represented for a knowledge agent are very important. Let's learn more about some of these representations. 

> Query: What are some representations of abstract concepts suitable for ontological engineering?
> 
>
>The provided context is Chapter 12 on Knowledge Representation with a subsection titled "Ontological Engineering." Ontological Engineering refers to the process of creating abstract representations of concepts suitable for knowledge engineering. The chapter presents a world ontology hierarchy that covers abstract concepts of the world, including humans, physical objects, events, time, beliefs, etc. 
>
>The purpose of the upper ontology is to provide a general framework of concepts that would enable agents to reason and solve problems efficiently in different domains. The upper ontology can be used to specify domain-specific axioms to build specialized ontologies suitable for a particular domain, such as a shopping or circuit engineering ontology. 
>
>The chapter highlights that ontological engineering is essential for complex domains such as shopping on the internet or driving a car in traffic. The ontology should be comprehensive enough to leave placeholders for future domain-specific knowledge to fit in. The ontology can handle natural kinds, actions, events, and time, and be represented in Situation calculus or more expressive representations such as Event calculus. 
>
>The chapter presents four ways of creating ontologies, including trained ontologists/logicians, importing categories from an existing database, parsing text documents, and enticing unskilled amateurs to participate. 
>
>The chapter concludes that the ontological engineering project has had limited success so far as no top AI application makes use of a shared ontology. Instead, most AI applications use domain-specific knowledge engineering. Philosophical and social considerations can hinder the agreement on a domain-general ontology. 
>
>In summary, the chapter presents the concept of ontological engineering as a process of creating abstract representations of concepts suitable for knowledge engineering. It presents a world ontology hierarchy covering various abstract concepts, and highlights that ontological engineering is vital for complex domains. The ontology should be comprehensive enough to handle different domains and to leave placeholders for future domain-specific knowledge to fit in.
Source pages: [456, 457, 455, 486, 488]

Most of the info seems to be in Chapter 12 - it covers a few different ways of representing 'ontologies', i.e. collections of knowlege. Wait a minute, aren't we forgetting something? 

> Query: Have you ever heard of model embeddings? 


> Based on the provided context, there is no direct mention of model embeddings. The context discusses different approaches to natural language processing, such as bags of words, link-analysis algorithms, information retrieval, information extraction, and statistical language systems. It also provides historical notes and references related to these topics. The exercises at the end of the context focus on testing comprehension and understanding of the topics covered, rather than specifically addressing model embeddings. Therefore, I am not sure if model embeddings are mentioned in this context or not.
Source pages: [901, 903, 781, 941, 888]

Ah. 

## Next Steps

This demo shows a basic functionality, but there's a lot more to try using pluggable knowledge. Here are some suggested next steps:

- Try loading your own data into a new collection, and running the demo with it. You may have to alter the prompts to get good results.  
- Right now every query is independent of the ones that previously occured in the conversation. OpenAI's chat API allows for a conversation to be chained, so that previous context is retained. This would be an easy extension to the demo application.
- OpenAI also has a [streaming API](https://platform.openai.com/docs/api-reference/chat/create#chat/create-stream), which allows the response from the model to be shown character by character. You could implement that here. 
- Check out the [Chroma on GitHub](https://github.com/chroma-core/chroma) - we welcome contributions from the community. 
- Tools like [Langchain](https://python.langchain.com/en/latest/) and [Llama Index](https://gpt-index.readthedocs.io/en/latest/index.html) are frameworks which make building complex LLM-enabled apps easier. They also use Chroma as a storage layer.

Chroma would love to feature your LLM-enabled Repls! Join [our Discord](https://discord.gg/MMeYNTmh3x) and show us what you've built! 