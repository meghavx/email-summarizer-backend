import os
from langchain_openai import ChatOpenAI
from langchain.chains import RetrievalQA
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings
from dotenv import load_dotenv
from openai import OpenAI
import json


load_dotenv()
os.environ["OPENAI_API_KEY"] = os.getenv("OPENAI_API_KEY")

def findFirstOccurance(text,ch):
    for i in range(0,len(text)):
        if(text[i] == ch):
            return i
    return None

def findLastOccurance(text,ch):
    lastIdx = -1
    for i in range(0, len(text)):
        if(text[i] == ch):
            lastIdx = i
    if (lastIdx == -1):
        return None
    return lastIdx

def get_string_between_braces(text):
    n1 = findFirstOccurance(text,'{')
    n2 = findLastOccurance(text,'}')
    if (not n1 and not n2):
        return None
    return text[n1:(n2+1)]

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

    json_format = "{\"sop_based_email_response\": \"<email response>\" , \"sop_coverage_percentage\": \"<percentage>%\" }"
    prompt = f"""
    You are a helpful assistant that generates responses based on company SOP guidelines. For the given email discussion:
    - generate a formal and professional response to this email, addressing each point appropriately.
    - Refer yourself as ABC support at the end of the mail.
    - Make sure to refer to the appropriate procedures mentioned in the subject and provide a comprehensive response,
    - including step-by-step guidelines, documentation, and any relevant timelines. Don't include the subject line in mail.
    - Do not mention subject in the response!
    - Also generate a percentage for how sufficient is the SOP document to generate an answer. Where 0% = topic not covered at all, 100% = topic is fully covered. 
    - Your output should be a JSON object that matches the following schema:
        {json_format}
    - Make sure it is a valid JSON object.
    - Use \n instead of whitespace or newline.
    - Never return anything other than a JSON object.

    Below are the emails asking about a specific process related to the company SOP.
    Email exchanges: 
    {email_message}
    """
    r = qa.run(prompt)
    response_from_llm  = get_string_between_braces(r)
    print("json response", response_from_llm)
    decodedResult = json.loads(response_from_llm)
    if (not decodedResult):
        return None
    percentage = int(decodedResult['sop_coverage_percentage'].replace('%','').strip())
    return (decodedResult['sop_based_email_response'], percentage)

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
