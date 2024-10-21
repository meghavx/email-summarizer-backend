import ollama

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
    prompt = f"""
    SOP:
    {sop_content}
   
    You are a helpful assistant that generates responses based on company SOP guidelines.
    Below are the emails asking about a specific process related to the company SOP.
    generate a formal and professional response to this email, addressing each point appropriately.
    Refer yourself as ABC support at the end of the mail.
    Make sure to refer to the appropriate procedures mentioned in the subject and provide a comprehensive response,
    including step-by-step guidelines, documentation, and any relevant timelines. Don't include the subject line in mail.
    Do not mention subject in the response!
    Email exchanges: 

    
    """

    response = ollama.chat(
        model='llama3.2',
        messages=[{'role': 'user', 'content': prompt + discussion_thread}]
    )
    return response['message']['content']
