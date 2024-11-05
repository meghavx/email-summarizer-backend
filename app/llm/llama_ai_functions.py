import ollama
import json
from typing import Optional, Tuple
from app.llm.utils import get_string_between_braces

def llama_get_summary_response(discussion_thread: str) -> str:
    prompt = f"""Please quickly summarize the following email thread in 2-3 points. 
                Include the main points, important decisions, and highlight any significant dates. 
                Here is the list of emails in the thread:\n\n"""
    response = ollama.chat(model='llama3.2', messages=[{
    'role': 'user',
    'content': prompt + discussion_thread,
    },])
    return (response['message']['content'])

def llama_get_answer_from_email(sop_content: str, discussion_thread: str) -> Optional[Tuple[str, int, str, str]]:
    json_format = """
        {\"sop_based_email_response\": \"<email response>\" ,
         \"sop_coverage_percentage\": \"<percentage>%\", 
         \"description_for_coverage_percentage\": \"<description>\" }, 
        \"FAQ_based_on_email\":\"<A_generalized_FAQ_question_thread_summarizes_email_discussion>\"
        """

    prompt = f"""
    SOP:
    {sop_content}
   
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
    {discussion_thread}
    """
    
    response = ollama.chat(
        model='llama3.2',
        messages=[{'role': 'user', 'content': prompt}]
    )
    response_from_llm = get_string_between_braces(response['message']['content'])
    print("json response", response_from_llm)
    decodedResult = json.loads(response_from_llm)
    if (not decodedResult):
        return None
    percentage = int(decodedResult['sop_coverage_percentage'].replace('%','').strip())
    coverage_description = decodedResult['description_for_coverage_percentage']
    faq = decodedResult['FAQ_based_on_email']
    return (decodedResult['sop_based_email_response'], percentage, coverage_description, faq)
