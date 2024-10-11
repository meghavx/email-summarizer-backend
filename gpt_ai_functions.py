import os
from langchain_openai import ChatOpenAI
from langchain.chains import RetrievalQA
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()
os.environ["OPENAI_API_KEY"] = os.getenv("OPENAI_API_KEY")

text_splitter = RecursiveCharacterTextSplitter(
    separators=['\n\n', '\n', '.', ','],
    chunk_size=750,
    chunk_overlap=50)

embeddings = OpenAIEmbeddings()
llm = ChatOpenAI(model="gpt-4", temperature=0.5, max_tokens=1000)
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"),)

def get_answer_from_email(email_subject, email_message, sender_name, doc_content):
    text_chunks = text_splitter.split_text(doc_content)
    vector_store = FAISS.from_texts(text_chunks, embedding=embeddings)
    qa = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=vector_store.as_retriever(search_kwargs={"k": 3})  # Increased k for broader search
    )

    prompt = f"""
    You are a helpful assistant that generates responses based on company SOP guidelines.
    The query is an email with the subject: "{email_subject}".
    Below is the email discussion asking about a specific process related to the company SOP.
    generate a formal and professional response to this email, addressing each point appropriately.
    Refer yourself as ABC support at the end of the mail.

    Email sender name: {sender_name}
    Email discussion: {email_message}

    Make sure to refer to the appropriate procedures mentioned in the subject and provide a comprehensive response,
    including step-by-step guidelines, documentation, and any relevant timelines. Don't add subject line in the response.
    
    """
    answer = qa.run(prompt)
    print ("got answer",answer)
    return answer

def get_summary_response(discussion_thread):
    completion = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
        {
            "role": "user", "content": f"""
            You are given below an email disucssion thread.
            Summarize the email  pointwise in 3 new lines - "
            1.Subject 
            2.Meeting Agenda 
            3.Important dates
            4. A quick summary of email disucssion
            "
            Discussion thread:

          """ + discussion_thread
         }
    ])
    response = completion.choices[0].message.content.strip()
    return response
