import os
from langchain_openai import ChatOpenAI
from langchain.chains import RetrievalQA
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings
from dotenv import load_dotenv
from openai import OpenAI
import json
from app.llm.utils import text_splitter, get_string_between_braces
from typing import Optional, Dict

load_dotenv()
openAiKey = os.getenv("OPENAI_API_KEY")
if openAiKey:
    os.environ["OPENAI_API_KEY"] = openAiKey

embeddings = OpenAIEmbeddings()
llm = ChatOpenAI(model="gpt-4o", temperature=0.5, max_tokens=1000)
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"),)

def get_answer_from_email(email_subject: str, email_message: str, sender_name: str, doc_content: str) -> Optional[Dict[str, str]]:
    text_chunks = text_splitter.split_text(doc_content)
    vector_store = FAISS.from_texts(text_chunks, embedding=embeddings)
    qa = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=vector_store.as_retriever(search_kwargs={"k": 3})  # Increased k for broader search
    )

    json_format = """
        {\"sop_based_email_response\": \"<email response>\" ,
         \"sop_coverage_percentage\": \"<percentage>%\", 
         \"description_for_coverage_percentage\": \"<description>\" }, 
        \"FAQ_based_on_email\":\"<A_generalized_FAQ_question_theat_summarizes_email_discussion>\"
        """
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
    print ("email_message",email_message)
    r = qa.run(prompt)
    response_from_llm  = get_string_between_braces(r)
    print("json response", response_from_llm)
    decodedResult = json.loads(response_from_llm)
    if (not decodedResult):
        return None
    percentage = int(decodedResult['sop_coverage_percentage'].replace('%','').strip())
    coverage_description = decodedResult['description_for_coverage_percentage']
    faq = decodedResult['FAQ_based_on_email']
    return (decodedResult['sop_based_email_response'], percentage, coverage_description, faq)

summaryDict = {
    "convert_to_spanish" : """- Language of the summary shall be in spanish language."""
    , "corporate_email" : """- The email discussion is in the corporate email. Add points related to corporate such as meeting agenda."""
    , "customer_support": """- The email discussion is in between customer and customer support. """
}

def getSummaryPrompt(summaryOption: str | None) -> str | None:
    if not summaryOption:
        return None
    if summaryOption in summaryDict:
        return summaryDict[summaryOption]
    return None

def get_summary_response(discussion_thread: str, summaryOption: Optional[str]) -> str:
    summaryPrompt = getSummaryPrompt(summaryOption)
    completion = client.chat.completions.create(
        model="gpt-4o",
        messages=[
        {
            "role": "user", "content": f"""

            Make a short summary of the following email thread in a professional format, highlight if there is any important date.
            {summaryPrompt}
            Discussion thread:

          """ + discussion_thread
         }
    ])
    #  The response content has to be in the same language as input language.
    response = completion.choices[0].message.content.strip()
    return response
