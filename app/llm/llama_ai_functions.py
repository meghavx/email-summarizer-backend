import ollama
import json

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

def llama_get_summary_response(discussion_thread):
    prompt = f"""Please quickly summarize the following email thread in 2-3 points. 
                Include the main points, important decisions, and highlight any significant dates. 
                Here is the list of emails in the thread:\n\n"""
    response = ollama.chat(model='llama3.2', messages=[{
    'role': 'user',
    'content': prompt + discussion_thread,
    },])
    return (response['message']['content'])

def llam_get_answer_from_email(sop_content, discussion_thread):
    json_format = "{\"sop_based_email_response\": \"<email response>\" , \"sop_coverage_percentage\": \"<percentage>%\", \"description_for_coverage_percentage\": \"<description>\" }"
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
    print ("response from llm", response_from_llm)
    if (not response_from_llm):
        return None
    decodedResult = json.loads(response_from_llm)
    percentage = int(decodedResult['sop_coverage_percentage'].replace('%','').strip())
    return (decodedResult['sop_based_email_response'], percentage)
